from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import uuid4

from pymongo import ReturnDocument
from pymongo.asynchronous.database import AsyncDatabase

from backend.app.errors import APIError


def utc_now() -> datetime:
    return datetime.now(UTC)


def public_document(document: dict[str, Any] | None) -> dict[str, Any] | None:
    if document is None:
        return None
    return {key: value for key, value in document.items() if key != "_id" and not key.endswith("_encrypted")}


class MongoStore:
    """All user-owned access is scoped here; callers cannot supply an unscoped filter."""

    mutable_collections = {"goals", "actions", "sessions", "financial_goals"}

    def __init__(self, db: AsyncDatabase[dict[str, Any]]) -> None:
        self.db = db

    async def find_user(self, user_id: str) -> dict[str, Any] | None:
        return public_document(await self.db.users.find_one({"id": user_id}))

    async def find_or_create_apple_user(self, claims: dict[str, Any]) -> dict[str, Any]:
        now = utc_now()
        user_id = str(uuid4())
        document = await self.db.users.find_one_and_update(
            {"apple_subject": str(claims["sub"])},
            {
                "$setOnInsert": {
                    "id": user_id,
                    "apple_subject": str(claims["sub"]),
                    "email": claims.get("email"),
                    "created_at": now,
                    "schema_version": 1,
                },
                "$set": {"updated_at": now, "apple_email_verified": claims.get("email_verified")},
            },
            upsert=True,
            return_document=ReturnDocument.AFTER,
        )
        assert document is not None
        return public_document(document) or {}

    async def list_owned(self, collection: str, user_id: str, limit: int = 500) -> list[dict[str, Any]]:
        cursor = self.db[collection].find({"user_id": user_id, "deleted_at": {"$exists": False}}).sort("updated_at", 1)
        return [public_document(item) or {} for item in await cursor.to_list(length=min(limit, 500))]

    async def get_owned(self, collection: str, user_id: str, entity_id: str) -> dict[str, Any]:
        item = await self.db[collection].find_one({"user_id": user_id, "id": entity_id, "deleted_at": {"$exists": False}})
        if item is None:
            raise APIError(404, "not_found", f"{collection.rstrip('s')} not found")
        return public_document(item) or {}

    async def upsert_owned(
        self,
        collection: str,
        user_id: str,
        entity_id: str,
        payload: dict[str, Any],
        *,
        base_updated_at: datetime | None,
        client_updated_at: datetime,
    ) -> dict[str, Any]:
        if collection not in self.mutable_collections:
            raise ValueError("collection is not client mutable")
        existing = await self.db[collection].find_one({"user_id": user_id, "id": entity_id})
        if existing and base_updated_at and existing["updated_at"] != base_updated_at:
            raise APIError(
                409,
                "sync_conflict",
                "The server record changed after the client copy",
                {"server": public_document(existing), "resolution": "server_wins"},
            )
        if existing and base_updated_at is None:
            raise APIError(409, "sync_conflict", "Creating a duplicate stable identifier is not allowed")
        now = utc_now()
        document = {
            **payload,
            "id": entity_id,
            "user_id": user_id,
            "updated_at": now,
            "client_updated_at": client_updated_at,
            "schema_version": 1,
        }
        if existing:
            document["created_at"] = existing["created_at"]
            await self.db[collection].replace_one({"user_id": user_id, "id": entity_id}, document)
        else:
            document["created_at"] = now
            await self.db[collection].insert_one(document)
        await self.record_change(user_id, collection, entity_id, "upsert", document)
        return public_document(document) or {}

    async def delete_owned(self, collection: str, user_id: str, entity_id: str) -> None:
        result = await self.db[collection].delete_one({"user_id": user_id, "id": entity_id})
        if result.deleted_count == 0:
            raise APIError(404, "not_found", f"{collection.rstrip('s')} not found")
        await self.record_change(user_id, collection, entity_id, "delete", None)

    async def record_change(
        self,
        user_id: str,
        entity_type: str,
        entity_id: str,
        operation: str,
        payload: dict[str, Any] | None,
    ) -> int:
        counter = await self.db.counters.find_one_and_update(
            {"_id": f"sync:{user_id}"},
            {"$inc": {"sequence": 1}},
            upsert=True,
            return_document=ReturnDocument.AFTER,
        )
        sequence = int(counter["sequence"])
        await self.db.sync_changes.insert_one(
            {
                "id": str(uuid4()),
                "user_id": user_id,
                "sequence": sequence,
                "entity_type": entity_type,
                "entity_id": entity_id,
                "operation": operation,
                "payload": public_document(payload),
                "created_at": utc_now(),
                "updated_at": utc_now(),
                "schema_version": 1,
            }
        )
        return sequence

    async def changes_after(self, user_id: str, cursor: int, limit: int = 500) -> tuple[list[dict[str, Any]], int]:
        query = self.db.sync_changes.find({"user_id": user_id, "sequence": {"$gt": cursor}}).sort("sequence", 1)
        changes = [public_document(item) or {} for item in await query.to_list(length=limit)]
        return changes, (changes[-1]["sequence"] if changes else cursor)

    async def apply_mutation(self, user_id: str, mutation: dict[str, Any]) -> dict[str, Any]:
        mutation_id = str(mutation["mutation_id"])
        receipt = await self.db.webhook_events.find_one({"provider": "ios_mutation", "event_id": mutation_id})
        if receipt:
            return {"mutation_id": mutation_id, "status": "already_applied"}
        if mutation["operation"] == "delete":
            try:
                await self.delete_owned(mutation["entity_type"], user_id, str(mutation["entity_id"]))
            except APIError as exc:
                if exc.status_code != 404:
                    raise
        else:
            await self.upsert_owned(
                mutation["entity_type"],
                user_id,
                str(mutation["entity_id"]),
                mutation["payload"],
                base_updated_at=mutation.get("base_updated_at"),
                client_updated_at=mutation["client_updated_at"],
            )
        await self.db.webhook_events.insert_one(
            {
                "provider": "ios_mutation",
                "event_id": mutation_id,
                "user_id": user_id,
                "received_at": utc_now(),
                "schema_version": 1,
            }
        )
        return {"mutation_id": mutation_id, "status": "applied"}

    async def create_refresh_token(self, user_id: str, token_hash: str, family_id: str, days: int) -> None:
        now = utc_now()
        await self.db.refresh_tokens.insert_one(
            {
                "id": str(uuid4()),
                "user_id": user_id,
                "token_hash": token_hash,
                "family_id": family_id,
                "created_at": now,
                "updated_at": now,
                "expires_at": now + timedelta(days=days),
                "schema_version": 1,
            }
        )

    async def rotate_refresh_token(self, old_hash: str, new_hash: str, days: int) -> dict[str, Any]:
        now = utc_now()
        old = await self.db.refresh_tokens.find_one({"token_hash": old_hash})
        if old is None or old["expires_at"] <= now:
            raise APIError(401, "invalid_refresh_token", "Refresh token is invalid or expired")
        if old.get("revoked_at"):
            await self.db.refresh_tokens.update_many(
                {"family_id": old["family_id"]}, {"$set": {"revoked_at": now, "revoke_reason": "reuse_detected"}}
            )
            raise APIError(401, "refresh_token_reuse", "Refresh token reuse was detected")
        result = await self.db.refresh_tokens.update_one(
            {"token_hash": old_hash, "revoked_at": {"$exists": False}},
            {"$set": {"revoked_at": now, "replaced_by_hash": new_hash, "updated_at": now}},
        )
        if result.modified_count != 1:
            raise APIError(401, "invalid_refresh_token", "Refresh token is invalid")
        await self.create_refresh_token(old["user_id"], new_hash, old["family_id"], days)
        return old

    async def revoke_refresh_token(self, token_hash: str, reason: str = "logout") -> None:
        await self.db.refresh_tokens.update_one(
            {"token_hash": token_hash}, {"$set": {"revoked_at": utc_now(), "revoke_reason": reason}}
        )

    async def delete_user(self, user_id: str) -> None:
        # A transaction is preferred on Atlas; repeatable deletes make this safe for retry.
        collections = [
            "refresh_tokens", "goals", "actions", "sessions", "financial_goals", "plaid_items",
            "financial_accounts", "transactions", "consent_records", "sync_changes", "webhook_events",
        ]
        for name in collections:
            await self.db[name].delete_many({"user_id": user_id})
        await self.db.users.delete_one({"id": user_id})

