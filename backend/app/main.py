import asyncio
import logging
import time
from collections import defaultdict, deque
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from datetime import UTC, datetime
from typing import Any, Annotated
from uuid import uuid4

from fastapi import BackgroundTasks, Depends, FastAPI, Header, Request, Response
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel

from backend.app.config import Settings, get_settings
from backend.app.database import mongo_lifespan
from backend.app.errors import APIError, api_error_handler
from backend.app.models import (
    ActionWrite,
    AppleLoginRequest,
    FinancialGoalWrite,
    GoalWrite,
    PlaidExchangeRequest,
    PlaidWebhook,
    RefreshRequest,
    SessionStart,
    SyncRequest,
    TokenPair,
)
from backend.app.plaid import PlaidCoordinator, PlaidHTTPService
from backend.app.repositories import MongoStore, utc_now
from backend.app.security import AppleIdentityVerifier, SecretBox, TokenService


logger = logging.getLogger("timebite.api")
bearer = HTTPBearer(auto_error=False)


class SessionTransition(BaseModel):
    occurred_at: datetime


class FixedWindowLimiter:
    """Single-process guard; production must also enforce a distributed edge limit."""

    def __init__(self, limit: int) -> None:
        self.limit = limit
        self.hits: dict[str, deque[float]] = defaultdict(deque)
        self.lock = asyncio.Lock()

    async def allow(self, key: str) -> bool:
        cutoff = time.monotonic() - 60
        async with self.lock:
            hits = self.hits[key]
            while hits and hits[0] < cutoff:
                hits.popleft()
            if len(hits) >= self.limit:
                return False
            hits.append(time.monotonic())
            return True


def create_app(settings: Settings | None = None) -> FastAPI:
    resolved = settings or get_settings()

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncIterator[None]:
        async with mongo_lifespan(resolved) as db:
            app.state.db = db
            app.state.store = MongoStore(db)
            app.state.tokens = TokenService(resolved)
            app.state.apple = AppleIdentityVerifier(resolved)
            app.state.plaid = None
            if resolved.plaid_client_id and resolved.plaid_secret:
                service = PlaidHTTPService(resolved)
                box = SecretBox(resolved.token_encryption_key.get_secret_value())
                app.state.plaid = PlaidCoordinator(app.state.store, service, box)
            yield

    app = FastAPI(title="TimeBite API", version="1.0.0", lifespan=lifespan)
    app.state.settings = resolved
    app.state.limiter = FixedWindowLimiter(resolved.rate_limit_per_minute)
    app.add_exception_handler(APIError, api_error_handler)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=resolved.allowed_origins,
        allow_credentials=False,
        allow_methods=["GET", "POST", "PUT", "DELETE"],
        allow_headers=["Authorization", "Content-Type", "X-Request-ID", "Plaid-Verification"],
    )

    @app.exception_handler(RequestValidationError)
    async def validation_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
        return JSONResponse(
            status_code=422,
            content={
                "error": {
                    "code": "validation_error",
                    "message": "Request validation failed",
                    "details": {"fields": exc.errors(include_url=False, include_context=False)},
                    "request_id": getattr(request.state, "request_id", None),
                }
            },
        )

    @app.middleware("http")
    async def request_context(request: Request, call_next: Any) -> Response:
        supplied = request.headers.get("X-Request-ID")
        request.state.request_id = supplied[:128] if supplied else str(uuid4())
        client = request.client.host if request.client else "unknown"
        if not await app.state.limiter.allow(client):
            response = JSONResponse(
                status_code=429,
                content={"error": {"code": "rate_limited", "message": "Too many requests", "request_id": request.state.request_id}},
            )
        else:
            response = await call_next(request)
        response.headers["X-Request-ID"] = request.state.request_id
        return response

    def store(request: Request) -> MongoStore:
        return request.app.state.store

    def tokens(request: Request) -> TokenService:
        return request.app.state.tokens

    def plaid(request: Request) -> PlaidCoordinator:
        coordinator = request.app.state.plaid
        if coordinator is None:
            raise APIError(503, "plaid_not_configured", "Plaid is not configured for this deployment")
        return coordinator

    async def current_user_id(
        request: Request,
        credential: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer)],
    ) -> str:
        if credential is None or credential.scheme.lower() != "bearer":
            raise APIError(401, "authentication_required", "A bearer access token is required")
        return request.app.state.tokens.verify_access(credential.credentials)

    UserID = Annotated[str, Depends(current_user_id)]
    Store = Annotated[MongoStore, Depends(store)]
    Tokens = Annotated[TokenService, Depends(tokens)]
    Plaid = Annotated[PlaidCoordinator, Depends(plaid)]

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {"status": "ok"}

    @app.get("/ready")
    async def ready(request: Request) -> dict[str, str]:
        try:
            await request.app.state.db.command("ping")
        except Exception as exc:
            raise APIError(503, "database_unavailable", "Database is not ready") from exc
        return {"status": "ready"}

    @app.post("/v1/auth/apple", response_model=TokenPair)
    async def apple_login(body: AppleLoginRequest, request: Request, db: Store, token_service: Tokens) -> TokenPair:
        claims = await request.app.state.apple.verify(body.identity_token, body.raw_nonce)
        user = await db.find_or_create_apple_user(claims)
        raw_refresh, refresh_hash = token_service.new_refresh_token()
        await db.create_refresh_token(user["id"], refresh_hash, str(uuid4()), resolved.refresh_token_days)
        access, expires = token_service.issue_access(user["id"])
        return TokenPair(access_token=access, refresh_token=raw_refresh, expires_in=expires)

    @app.post("/v1/auth/refresh", response_model=TokenPair)
    async def refresh(body: RefreshRequest, db: Store, token_service: Tokens) -> TokenPair:
        new_raw, new_hash = token_service.new_refresh_token()
        old = await db.rotate_refresh_token(token_service.hash_refresh_token(body.refresh_token), new_hash, resolved.refresh_token_days)
        access, expires = token_service.issue_access(old["user_id"])
        return TokenPair(access_token=access, refresh_token=new_raw, expires_in=expires)

    @app.post("/v1/auth/logout", status_code=204)
    async def logout(body: RefreshRequest, db: Store, token_service: Tokens) -> Response:
        await db.revoke_refresh_token(token_service.hash_refresh_token(body.refresh_token))
        return Response(status_code=204)

    @app.get("/v1/me")
    async def me(user_id: UserID, db: Store) -> dict[str, Any]:
        user = await db.find_user(user_id)
        if not user:
            raise APIError(404, "not_found", "User not found")
        return user

    @app.delete("/v1/account", status_code=204)
    async def delete_account(user_id: UserID, db: Store, plaid_coordinator: Plaid) -> Response:
        items = await db.list_owned("plaid_items", user_id)
        for item in items:
            await plaid_coordinator.disconnect(user_id, item["id"])
        await db.delete_user(user_id)
        return Response(status_code=204)

    def install_crud(path: str, collection: str, model: type[BaseModel]) -> None:
        async def list_entities(user_id: UserID, db: Store) -> list[dict[str, Any]]:
            return await db.list_owned(collection, user_id)

        async def get_entity(entity_id: str, user_id: UserID, db: Store) -> dict[str, Any]:
            return await db.get_owned(collection, user_id, entity_id)

        async def put_entity(entity_id: str, body: model, user_id: UserID, db: Store) -> dict[str, Any]:  # type: ignore[valid-type]
            if str(body.id) != entity_id:  # type: ignore[attr-defined]
                raise APIError(422, "id_mismatch", "Path and body identifiers must match")
            data = body.model_dump(exclude={"id", "base_updated_at", "client_updated_at"})
            return await db.upsert_owned(
                collection,
                user_id,
                entity_id,
                data,
                base_updated_at=body.base_updated_at,  # type: ignore[attr-defined]
                client_updated_at=body.client_updated_at,  # type: ignore[attr-defined]
            )

        async def delete_entity(entity_id: str, user_id: UserID, db: Store) -> Response:
            await db.delete_owned(collection, user_id, entity_id)
            return Response(status_code=204)

        app.add_api_route(path, list_entities, methods=["GET"], name=f"list_{collection}")
        app.add_api_route(f"{path}/{{entity_id}}", get_entity, methods=["GET"], name=f"get_{collection}")
        app.add_api_route(f"{path}/{{entity_id}}", put_entity, methods=["PUT"], name=f"put_{collection}")
        app.add_api_route(f"{path}/{{entity_id}}", delete_entity, methods=["DELETE"], status_code=204, name=f"delete_{collection}")

    install_crud("/v1/goals", "goals", GoalWrite)
    install_crud("/v1/actions", "actions", ActionWrite)
    install_crud("/v1/financial-goals", "financial_goals", FinancialGoalWrite)

    @app.post("/v1/sessions/start")
    async def start_session(body: SessionStart, user_id: UserID, db: Store) -> dict[str, Any]:
        return await db.upsert_owned(
            "sessions",
            user_id,
            str(body.id),
            {"action_id": str(body.action_id) if body.action_id else None, "started_at": body.started_at, "status": "active"},
            base_updated_at=None,
            client_updated_at=body.started_at,
        )

    async def transition_session(entity_id: str, status: str, body: SessionTransition, user_id: str, db: MongoStore) -> dict[str, Any]:
        current = await db.get_owned("sessions", user_id, entity_id)
        payload = {key: value for key, value in current.items() if key not in {"id", "user_id", "created_at", "updated_at", "schema_version"}}
        payload.update({"status": status, f"{status}_at": body.occurred_at})
        return await db.upsert_owned(
            "sessions", user_id, entity_id, payload, base_updated_at=current["updated_at"], client_updated_at=body.occurred_at
        )

    @app.post("/v1/sessions/{entity_id}/pause")
    async def pause_session(entity_id: str, body: SessionTransition, user_id: UserID, db: Store) -> dict[str, Any]:
        return await transition_session(entity_id, "paused", body, user_id, db)

    @app.post("/v1/sessions/{entity_id}/complete")
    async def complete_session(entity_id: str, body: SessionTransition, user_id: UserID, db: Store) -> dict[str, Any]:
        return await transition_session(entity_id, "completed", body, user_id, db)

    @app.get("/v1/sync/initial")
    async def initial_sync(user_id: UserID, db: Store) -> dict[str, Any]:
        collections = ("goals", "actions", "sessions", "financial_goals", "financial_accounts", "transactions", "plaid_items")
        data = {name: await db.list_owned(name, user_id) for name in collections}
        _, cursor = await db.changes_after(user_id, 0)
        return {"data": data, "cursor": cursor, "server_time": utc_now()}

    @app.post("/v1/sync")
    async def incremental_sync(body: SyncRequest, user_id: UserID, db: Store) -> dict[str, Any]:
        results = []
        for mutation in body.mutations:
            try:
                results.append(await db.apply_mutation(user_id, mutation.model_dump()))
            except APIError as exc:
                if exc.code != "sync_conflict":
                    raise
                results.append({"mutation_id": str(mutation.mutation_id), "status": "conflict", "details": exc.details})
        changes, next_cursor = await db.changes_after(user_id, body.cursor)
        return {"mutation_results": results, "changes": changes, "cursor": next_cursor, "server_time": utc_now()}

    @app.post("/v1/plaid/link-token")
    async def link_token(user_id: UserID, coordinator: Plaid) -> dict[str, Any]:
        return await coordinator.service.create_link_token(user_id)

    @app.post("/v1/plaid/exchange", status_code=201)
    async def plaid_exchange(body: PlaidExchangeRequest, user_id: UserID, coordinator: Plaid) -> dict[str, Any]:
        return await coordinator.exchange(user_id, body.public_token)

    @app.post("/v1/plaid/webhooks", status_code=202)
    async def plaid_webhook(
        background: BackgroundTasks,
        request: Request,
        plaid_verification: Annotated[str | None, Header(alias="Plaid-Verification")] = None,
    ) -> dict[str, str]:
        coordinator = plaid(request)
        raw_body = await request.body()
        try:
            body = PlaidWebhook.model_validate_json(raw_body)
        except Exception as exc:
            raise APIError(422, "validation_error", "Plaid webhook body is invalid") from exc
        if resolved.plaid_webhook_verification:
            if not plaid_verification:
                raise APIError(401, "missing_webhook_signature", "Plaid webhook signature is required")
            await coordinator.service.verify_webhook(plaid_verification, raw_body)
        background.add_task(coordinator.handle_webhook, body.model_dump())
        return {"status": "accepted"}

    @app.get("/v1/finance/accounts")
    async def finance_accounts(user_id: UserID, db: Store) -> list[dict[str, Any]]:
        return await db.list_owned("financial_accounts", user_id)

    @app.get("/v1/finance/transactions")
    async def finance_transactions(user_id: UserID, db: Store) -> list[dict[str, Any]]:
        return await db.list_owned("transactions", user_id)

    @app.post("/v1/plaid/items/{item_id}/update-link-token")
    async def update_link_token(item_id: str, user_id: UserID, db: Store, coordinator: Plaid) -> dict[str, Any]:
        item = await db.db.plaid_items.find_one({"user_id": user_id, "id": item_id})
        if item is None:
            raise APIError(404, "not_found", "Plaid item not found")
        access = coordinator.secret_box.decrypt(item["access_token_encrypted"])
        return await coordinator.service.create_link_token(user_id, access)

    @app.delete("/v1/plaid/items/{item_id}", status_code=204)
    async def disconnect_item(item_id: str, user_id: UserID, coordinator: Plaid) -> Response:
        await coordinator.disconnect(user_id, item_id)
        return Response(status_code=204)

    return app


app = create_app()
