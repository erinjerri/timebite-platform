"""Plaid Link and read-only transaction-sync route adapters.

Access tokens are accepted only by the server-side client and repository. No
handler in this module returns credentials or implements money movement.
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass
from typing import Any, Mapping, Protocol
from urllib.request import Request, urlopen


class PlaidItemRepository(Protocol):
    def save_item(self, user_id: str, item_id: str, access_token: str) -> None: ...

    def get_item(self, user_id: str) -> Mapping[str, str] | None: ...

    def save_transaction_sync(
        self,
        user_id: str,
        *,
        added: list[dict[str, Any]],
        modified: list[dict[str, Any]],
        removed: list[dict[str, Any]],
        next_cursor: str,
    ) -> None: ...


class PlaidAPIClient(Protocol):
    def create_link_token(self, user_id: str) -> dict[str, Any]: ...

    def exchange_public_token(self, public_token: str) -> dict[str, Any]: ...

    def sync_transactions(
        self, access_token: str, cursor: str | None
    ) -> dict[str, Any]: ...


@dataclass(frozen=True)
class PlaidHTTPClient:
    client_id: str
    secret: str
    environment: str = "sandbox"

    @classmethod
    def from_environment(cls) -> "PlaidHTTPClient":
        client_id = os.environ.get("PLAID_CLIENT_ID", "")
        secret = os.environ.get("PLAID_SECRET", "")
        environment = os.environ.get("PLAID_ENV", "sandbox").lower()
        if not client_id or not secret:
            raise RuntimeError("PLAID_CLIENT_ID and PLAID_SECRET must be configured")
        if environment not in {"sandbox", "development", "production"}:
            raise RuntimeError("PLAID_ENV must be sandbox, development, or production")
        return cls(client_id=client_id, secret=secret, environment=environment)

    def create_link_token(self, user_id: str) -> dict[str, Any]:
        return self._post(
            "/link/token/create",
            {
                "client_name": "TimeBite",
                "country_codes": ["US"],
                "language": "en",
                "products": ["transactions"],
                "user": {"client_user_id": user_id},
            },
        )

    def exchange_public_token(self, public_token: str) -> dict[str, Any]:
        return self._post(
            "/item/public_token/exchange", {"public_token": public_token}
        )

    def sync_transactions(
        self, access_token: str, cursor: str | None
    ) -> dict[str, Any]:
        payload: dict[str, Any] = {"access_token": access_token}
        if cursor:
            payload["cursor"] = cursor
        return self._post("/transactions/sync", payload)

    def _post(self, path: str, payload: Mapping[str, Any]) -> dict[str, Any]:
        body = {
            "client_id": self.client_id,
            "secret": self.secret,
            **payload,
        }
        request = Request(
            f"https://{self.environment}.plaid.com{path}",
            data=json.dumps(body).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urlopen(request, timeout=30) as response:  # nosec B310
            return json.loads(response.read().decode("utf-8"))


@dataclass(frozen=True)
class PlaidRoutes:
    repository: PlaidItemRepository
    client: PlaidAPIClient

    def create_link_token(self, user_id: str) -> dict[str, str]:
        payload = self.client.create_link_token(user_id)
        return {"link_token": str(payload["link_token"])}

    def exchange_token(self, user_id: str, public_token: str) -> dict[str, bool]:
        payload = self.client.exchange_public_token(public_token)
        self.repository.save_item(
            user_id,
            item_id=str(payload["item_id"]),
            access_token=str(payload["access_token"]),
        )
        return {"linked": True}

    def sync_transactions(self, user_id: str) -> dict[str, Any]:
        item = self.repository.get_item(user_id)
        if not item:
            raise LookupError("No Plaid item is linked for this user")

        cursor = item.get("cursor") or None
        added: list[dict[str, Any]] = []
        modified: list[dict[str, Any]] = []
        removed: list[dict[str, Any]] = []

        while True:
            payload = self.client.sync_transactions(item["access_token"], cursor)
            added.extend(payload.get("added", []))
            modified.extend(payload.get("modified", []))
            removed.extend(payload.get("removed", []))
            cursor = str(payload.get("next_cursor", cursor or ""))
            if not payload.get("has_more", False):
                break

        self.repository.save_transaction_sync(
            user_id,
            added=added,
            modified=modified,
            removed=removed,
            next_cursor=cursor or "",
        )
        return {
            "added": added,
            "modified": modified,
            "removed": removed,
            "next_cursor": cursor or "",
        }


def create_link_token(
    user_id: str,
    repository: PlaidItemRepository,
    client: PlaidAPIClient,
) -> dict[str, str]:
    return PlaidRoutes(repository, client).create_link_token(user_id)


def exchange_public_token(
    user_id: str,
    public_token: str,
    repository: PlaidItemRepository,
    client: PlaidAPIClient,
) -> dict[str, bool]:
    return PlaidRoutes(repository, client).exchange_token(user_id, public_token)


def sync_transactions(
    user_id: str,
    repository: PlaidItemRepository,
    client: PlaidAPIClient,
) -> dict[str, Any]:
    return PlaidRoutes(repository, client).sync_transactions(user_id)


try:
    from fastapi import APIRouter, Depends, Header, HTTPException
    from pydantic import BaseModel
except ImportError:  # pragma: no cover - FastAPI remains optional in this repo.
    router = None
else:
    router = APIRouter()

    class LinkTokenRequest(BaseModel):
        user_id: str

    class ExchangeTokenRequest(BaseModel):
        public_token: str

    def get_repository() -> PlaidItemRepository:
        raise RuntimeError("PlaidItemRepository dependency is not configured")

    def get_plaid_client() -> PlaidAPIClient:
        return PlaidHTTPClient.from_environment()

    def get_current_user_id(
        x_timebite_user_id: str = Header(..., alias="X-TimeBite-User-ID"),
    ) -> str:
        # Replace this adapter with verified session/JWT identity when the API
        # app is mounted. Route logic never trusts the body over this identity.
        return x_timebite_user_id

    @router.post("/plaid/link-token")
    def post_link_token(
        body: LinkTokenRequest,
        user_id: str = Depends(get_current_user_id),
        repository: PlaidItemRepository = Depends(get_repository),
        client: PlaidAPIClient = Depends(get_plaid_client),
    ) -> dict[str, str]:
        if body.user_id != user_id:
            raise HTTPException(status_code=403, detail="User identity mismatch")
        return create_link_token(user_id, repository, client)

    @router.post("/plaid/exchange-token")
    def post_exchange_token(
        body: ExchangeTokenRequest,
        user_id: str = Depends(get_current_user_id),
        repository: PlaidItemRepository = Depends(get_repository),
        client: PlaidAPIClient = Depends(get_plaid_client),
    ) -> dict[str, bool]:
        return exchange_public_token(
            user_id, body.public_token, repository, client
        )

    @router.get("/plaid/transactions/sync")
    def get_transaction_sync(
        user_id: str = Depends(get_current_user_id),
        repository: PlaidItemRepository = Depends(get_repository),
        client: PlaidAPIClient = Depends(get_plaid_client),
    ) -> dict[str, Any]:
        try:
            return sync_transactions(user_id, repository, client)
        except LookupError as error:
            raise HTTPException(status_code=409, detail=str(error)) from error

