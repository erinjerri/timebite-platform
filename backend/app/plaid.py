from __future__ import annotations

import hashlib
import json
import secrets
import time
from abc import ABC, abstractmethod
from decimal import Decimal, ROUND_HALF_EVEN
from typing import Any
from uuid import uuid4

import httpx
import jwt
from pymongo import UpdateOne

from backend.app.config import Settings
from backend.app.errors import APIError
from backend.app.repositories import MongoStore, utc_now
from backend.app.security import SecretBox


class PlaidService(ABC):
    @abstractmethod
    async def create_link_token(self, user_id: str, access_token: str | None = None) -> dict[str, Any]: ...

    @abstractmethod
    async def exchange_public_token(self, public_token: str) -> dict[str, Any]: ...

    @abstractmethod
    async def accounts(self, access_token: str) -> dict[str, Any]: ...

    @abstractmethod
    async def transactions_sync(self, access_token: str, cursor: str | None) -> dict[str, Any]: ...

    @abstractmethod
    async def remove_item(self, access_token: str) -> None: ...

    @abstractmethod
    async def verify_webhook(self, signature: str, raw_body: bytes) -> None: ...


class PlaidHTTPService(PlaidService):
    def __init__(self, settings: Settings, client: httpx.AsyncClient | None = None) -> None:
        if not settings.plaid_client_id or not settings.plaid_secret:
            raise RuntimeError("Plaid credentials are not configured")
        self.settings = settings
        self.client = client or httpx.AsyncClient(base_url=f"https://{settings.plaid_environment}.plaid.com", timeout=20)

    async def _post(self, path: str, payload: dict[str, Any]) -> dict[str, Any]:
        body = {
            "client_id": self.settings.plaid_client_id.get_secret_value(),
            "secret": self.settings.plaid_secret.get_secret_value(),
            **payload,
        }
        response = await self.client.post(path, json=body)
        data = response.json()
        if response.is_error:
            code = data.get("error_code", "plaid_error")
            status = 409 if code == "TRANSACTIONS_SYNC_MUTATION_DURING_PAGINATION" else 502
            raise APIError(status, code.lower(), "Plaid request failed")
        return data

    async def create_link_token(self, user_id: str, access_token: str | None = None) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "client_name": "TimeBite",
            "country_codes": ["US"],
            "language": "en",
            "user": {"client_user_id": user_id},
            "webhook": f"{self.settings.public_base_url}/v1/plaid/webhooks",
        }
        if self.settings.plaid_redirect_uri:
            payload["redirect_uri"] = self.settings.plaid_redirect_uri
        if access_token:
            payload["access_token"] = access_token
        else:
            payload["products"] = ["transactions"]
        return await self._post("/link/token/create", payload)

    async def exchange_public_token(self, public_token: str) -> dict[str, Any]:
        return await self._post("/item/public_token/exchange", {"public_token": public_token})

    async def accounts(self, access_token: str) -> dict[str, Any]:
        return await self._post("/accounts/get", {"access_token": access_token})

    async def transactions_sync(self, access_token: str, cursor: str | None) -> dict[str, Any]:
        payload: dict[str, Any] = {"access_token": access_token, "count": 500}
        if cursor:
            payload["cursor"] = cursor
        return await self._post("/transactions/sync", payload)

    async def remove_item(self, access_token: str) -> None:
        await self._post("/item/remove", {"access_token": access_token})

    async def verify_webhook(self, signature: str, raw_body: bytes) -> None:
        try:
            header = jwt.get_unverified_header(signature)
            if header.get("alg") != "ES256" or not header.get("kid"):
                raise ValueError("invalid JWT header")
            response = await self._post("/webhook_verification_key/get", {"key_id": header["kid"]})
            key = jwt.PyJWK.from_dict(response["key"]).key
            claims = jwt.decode(
                signature,
                key,
                algorithms=["ES256"],
                options={"verify_aud": False, "require": ["iat", "request_body_sha256"]},
            )
            age = time.time() - float(claims["iat"])
            if age < -30 or age > 300:
                raise ValueError("signature outside replay window")
            body_hash = hashlib.sha256(raw_body).hexdigest()
            if not secrets.compare_digest(body_hash, str(claims["request_body_sha256"])):
                raise ValueError("body digest mismatch")
        except Exception as exc:
            raise APIError(401, "invalid_webhook_signature", "Plaid webhook signature is invalid") from exc


class PlaidCoordinator:
    def __init__(self, store: MongoStore, service: PlaidService, secret_box: SecretBox) -> None:
        self.store = store
        self.service = service
        self.secret_box = secret_box

    async def exchange(self, user_id: str, public_token: str) -> dict[str, Any]:
        result = await self.service.exchange_public_token(public_token)
        now = utc_now()
        internal_id = str(uuid4())
        item = {
            "id": internal_id,
            "user_id": user_id,
            "plaid_item_id": result["item_id"],
            "access_token_encrypted": self.secret_box.encrypt(result["access_token"]),
            "transactions_cursor": None,
            "status": "active",
            "created_at": now,
            "updated_at": now,
            "schema_version": 1,
        }
        await self.store.db.plaid_items.insert_one(item)
        accounts = await self.service.accounts(result["access_token"])
        await self._persist_accounts(user_id, internal_id, accounts.get("accounts", []))
        # Plaid requires the first Transactions Sync call after Item creation.
        await self.sync_item(item)
        return {"id": internal_id, "status": "active"}

    async def _persist_accounts(self, user_id: str, item_id: str, accounts: list[dict[str, Any]]) -> None:
        now = utc_now()
        operations = []
        for account in accounts:
            balances = account.get("balances", {})
            currency = balances.get("iso_currency_code") or "USD"
            operations.append(
                UpdateOne(
                    {"plaid_account_id": account["account_id"]},
                    {
                        "$set": {
                            "user_id": user_id,
                            "plaid_item_id": item_id,
                            "name": account.get("name", "Account"),
                            "official_name": account.get("official_name"),
                            "mask": account.get("mask"),
                            "type": account.get("type"),
                            "subtype": account.get("subtype"),
                            "currency": currency,
                            "current_balance_minor_units": money_to_minor(balances.get("current"), currency),
                            "updated_at": now,
                            "schema_version": 1,
                        },
                        "$setOnInsert": {"id": str(uuid4()), "created_at": now},
                    },
                    upsert=True,
                )
            )
        if operations:
            await self.store.db.financial_accounts.bulk_write(operations)

    async def sync_item(self, item: dict[str, Any]) -> None:
        access_token = self.secret_box.decrypt(item["access_token_encrypted"])
        starting_cursor = item.get("transactions_cursor")
        cursor = starting_cursor
        added: list[dict[str, Any]] = []
        modified: list[dict[str, Any]] = []
        removed: list[dict[str, Any]] = []
        for _ in range(100):
            try:
                page = await self.service.transactions_sync(access_token, cursor)
            except APIError as exc:
                if exc.code == "transactions_sync_mutation_during_pagination":
                    return await self.sync_item({**item, "transactions_cursor": starting_cursor})
                raise
            added.extend(page.get("added", []))
            modified.extend(page.get("modified", []))
            removed.extend(page.get("removed", []))
            cursor = page["next_cursor"]
            if not page.get("has_more"):
                break
        else:
            raise APIError(502, "plaid_pagination_limit", "Plaid sync exceeded the safety page limit")

        # Apply the complete page set before advancing the durable cursor.
        await self._apply_transactions(item["user_id"], item["id"], added + modified, removed)
        await self.store.db.plaid_items.update_one(
            {"user_id": item["user_id"], "id": item["id"], "transactions_cursor": starting_cursor},
            {"$set": {"transactions_cursor": cursor, "updated_at": utc_now(), "status": "active"}},
        )

    async def _apply_transactions(
        self, user_id: str, item_id: str, changed: list[dict[str, Any]], removed: list[dict[str, Any]]
    ) -> None:
        now = utc_now()
        operations = []
        for transaction in changed:
            currency = transaction.get("iso_currency_code") or "USD"
            operations.append(
                UpdateOne(
                    {"plaid_transaction_id": transaction["transaction_id"]},
                    {
                        "$set": {
                            "user_id": user_id,
                            "plaid_item_id": item_id,
                            "plaid_account_id": transaction["account_id"],
                            "name": transaction.get("merchant_name") or transaction.get("name", "Transaction"),
                            "amount_minor_units": money_to_minor(transaction.get("amount"), currency),
                            "currency": currency,
                            "authorized_date": transaction.get("authorized_date") or transaction.get("date"),
                            "pending": bool(transaction.get("pending")),
                            "updated_at": now,
                            "schema_version": 1,
                        },
                        "$setOnInsert": {"id": str(uuid4()), "created_at": now},
                    },
                    upsert=True,
                )
            )
        if operations:
            await self.store.db.transactions.bulk_write(operations)
        removed_ids = [item["transaction_id"] for item in removed]
        if removed_ids:
            await self.store.db.transactions.delete_many(
                {"user_id": user_id, "plaid_transaction_id": {"$in": removed_ids}}
            )

    async def handle_webhook(self, payload: dict[str, Any]) -> None:
        canonical = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
        event_id = hashlib.sha256(canonical).hexdigest()
        event_query = {"provider": "plaid", "event_id": event_id}
        existing = await self.store.db.webhook_events.find_one(event_query)
        if existing and existing.get("status") == "completed":
            return
        now = utc_now()
        if existing:
            await self.store.db.webhook_events.update_one(
                event_query, {"$set": {"status": "processing", "last_attempt_at": now}}
            )
        else:
            await self.store.db.webhook_events.insert_one(
                {
                    **event_query,
                    "status": "processing",
                    "received_at": now,
                    "last_attempt_at": now,
                    "schema_version": 1,
                }
            )
        try:
            item = await self.store.db.plaid_items.find_one({"plaid_item_id": payload.get("item_id")})
            if item is not None:
                await self.store.db.webhook_events.update_one(event_query, {"$set": {"user_id": item["user_id"]}})
                if (
                    payload.get("webhook_type") == "TRANSACTIONS"
                    and payload.get("webhook_code") == "SYNC_UPDATES_AVAILABLE"
                ):
                    await self.sync_item(item)
                error_code = (payload.get("error") or {}).get("error_code")
                if error_code == "ITEM_LOGIN_REQUIRED":
                    await self.store.db.plaid_items.update_one(
                        {"id": item["id"], "user_id": item["user_id"]},
                        {"$set": {"status": "login_required", "updated_at": now}},
                    )
            await self.store.db.webhook_events.update_one(
                event_query, {"$set": {"status": "completed", "completed_at": utc_now()}}
            )
        except Exception:
            await self.store.db.webhook_events.update_one(
                event_query, {"$set": {"status": "failed", "failed_at": utc_now()}}
            )
            raise

    async def disconnect(self, user_id: str, item_id: str) -> None:
        item = await self.store.db.plaid_items.find_one({"id": item_id, "user_id": user_id})
        if item is None:
            raise APIError(404, "not_found", "Plaid item not found")
        await self.service.remove_item(self.secret_box.decrypt(item["access_token_encrypted"]))
        await self.store.db.transactions.delete_many({"user_id": user_id, "plaid_item_id": item_id})
        await self.store.db.financial_accounts.delete_many({"user_id": user_id, "plaid_item_id": item_id})
        await self.store.db.plaid_items.delete_one({"user_id": user_id, "id": item_id})


def money_to_minor(value: Any, currency: str) -> int | None:
    if value is None:
        return None
    exponent = 0 if currency.upper() in {"JPY", "KRW"} else 2
    multiplier = Decimal(10) ** exponent
    return int((Decimal(str(value)) * multiplier).quantize(Decimal("1"), rounding=ROUND_HALF_EVEN))
