from __future__ import annotations

import base64
from types import SimpleNamespace
from typing import Any

import pytest

from backend.app.plaid import PlaidCoordinator, PlaidService
from backend.app.security import SecretBox


def matches(document: dict[str, Any], query: dict[str, Any]) -> bool:
    for key, value in query.items():
        if isinstance(value, dict) and "$in" in value:
            if document.get(key) not in value["$in"]:
                return False
        elif document.get(key) != value:
            return False
    return True


class Result:
    def __init__(self, deleted_count: int = 0, modified_count: int = 0) -> None:
        self.deleted_count = deleted_count
        self.modified_count = modified_count


class MemoryCollection:
    def __init__(self, documents: list[dict[str, Any]] | None = None) -> None:
        self.documents = documents or []

    async def find_one(self, query: dict[str, Any]) -> dict[str, Any] | None:
        return next((item for item in self.documents if matches(item, query)), None)

    async def insert_one(self, document: dict[str, Any]) -> Result:
        self.documents.append(document.copy())
        return Result()

    async def update_one(self, query: dict[str, Any], update: dict[str, Any]) -> Result:
        item = await self.find_one(query)
        if item is None:
            return Result()
        item.update(update.get("$set", {}))
        return Result(modified_count=1)

    async def delete_many(self, query: dict[str, Any]) -> Result:
        before = len(self.documents)
        self.documents = [item for item in self.documents if not matches(item, query)]
        return Result(deleted_count=before - len(self.documents))

    async def bulk_write(self, operations: list[Any]) -> Result:
        for operation in operations:
            query = operation._filter
            update = operation._doc
            item = await self.find_one(query)
            if item is None:
                item = {**query, **update.get("$setOnInsert", {})}
                self.documents.append(item)
            item.update(update.get("$set", {}))
        return Result(modified_count=len(operations))


class MemoryDatabase:
    def __init__(self, item: dict[str, Any]) -> None:
        self.plaid_items = MemoryCollection([item])
        self.transactions = MemoryCollection()
        self.financial_accounts = MemoryCollection()
        self.webhook_events = MemoryCollection()


class MockPlaid(PlaidService):
    def __init__(self) -> None:
        self.calls = 0
        self.pages: list[dict[str, Any]] = []

    async def create_link_token(self, user_id: str, access_token: str | None = None) -> dict[str, Any]:
        return {"link_token": "link-sandbox-test"}

    async def exchange_public_token(self, public_token: str) -> dict[str, Any]:
        return {"access_token": "access-sandbox-test", "item_id": "plaid-item"}

    async def accounts(self, access_token: str) -> dict[str, Any]:
        return {"accounts": []}

    async def transactions_sync(self, access_token: str, cursor: str | None) -> dict[str, Any]:
        page = self.pages[self.calls]
        self.calls += 1
        return page

    async def remove_item(self, access_token: str) -> None: return None
    async def verify_webhook(self, signature: str, raw_body: bytes) -> None: return None


class FailsOncePlaid(MockPlaid):
    failed = False

    async def transactions_sync(self, access_token: str, cursor: str | None) -> dict[str, Any]:
        if not self.failed:
            self.failed = True
            raise RuntimeError("transient Plaid failure")
        return await super().transactions_sync(access_token, cursor)


@pytest.mark.asyncio
async def test_paginated_added_modified_removed_reconcile_before_cursor_advance() -> None:
    box = SecretBox(base64.urlsafe_b64encode(b"p" * 32).decode())
    item = {
        "id": "internal-item",
        "user_id": "user-a",
        "plaid_item_id": "plaid-item",
        "access_token_encrypted": box.encrypt("access-sandbox-test"),
        "transactions_cursor": None,
    }
    database = MemoryDatabase(item)
    service = MockPlaid()
    service.pages = [
        {
            "added": [{"transaction_id": "txn-1", "account_id": "acct-1", "name": "Coffee", "amount": "4.25", "iso_currency_code": "USD", "date": "2026-07-20"}],
            "modified": [], "removed": [], "next_cursor": "cursor-1", "has_more": True,
        },
        {
            "added": [{"transaction_id": "txn-2", "account_id": "acct-1", "name": "Pending", "amount": "10.00", "iso_currency_code": "USD", "date": "2026-07-20"}],
            "modified": [{"transaction_id": "txn-1", "account_id": "acct-1", "name": "Coffee Shop", "amount": "4.50", "iso_currency_code": "USD", "date": "2026-07-20"}],
            "removed": [{"transaction_id": "txn-2"}], "next_cursor": "cursor-2", "has_more": False,
        },
    ]
    coordinator = PlaidCoordinator(SimpleNamespace(db=database), service, box)  # type: ignore[arg-type]
    await coordinator.sync_item(item)
    assert service.calls == 2
    assert database.plaid_items.documents[0]["transactions_cursor"] == "cursor-2"
    assert [(row["plaid_transaction_id"], row["name"], row["amount_minor_units"]) for row in database.transactions.documents] == [
        ("txn-1", "Coffee Shop", 450)
    ]


@pytest.mark.asyncio
async def test_duplicate_webhook_is_idempotent() -> None:
    box = SecretBox(base64.urlsafe_b64encode(b"p" * 32).decode())
    item = {
        "id": "internal-item", "user_id": "user-a", "plaid_item_id": "plaid-item",
        "access_token_encrypted": box.encrypt("access-sandbox-test"), "transactions_cursor": "cursor-1",
    }
    database = MemoryDatabase(item)
    service = MockPlaid()
    service.pages = [{"added": [], "modified": [], "removed": [], "next_cursor": "cursor-2", "has_more": False}]
    coordinator = PlaidCoordinator(SimpleNamespace(db=database), service, box)  # type: ignore[arg-type]
    payload = {"webhook_type": "TRANSACTIONS", "webhook_code": "SYNC_UPDATES_AVAILABLE", "item_id": "plaid-item"}
    await coordinator.handle_webhook(payload)
    await coordinator.handle_webhook(payload)
    assert service.calls == 1
    assert len(database.webhook_events.documents) == 1
    assert database.webhook_events.documents[0]["status"] == "completed"


@pytest.mark.asyncio
async def test_failed_webhook_can_be_retried() -> None:
    box = SecretBox(base64.urlsafe_b64encode(b"p" * 32).decode())
    item = {
        "id": "internal-item", "user_id": "user-a", "plaid_item_id": "plaid-item",
        "access_token_encrypted": box.encrypt("access-sandbox-test"), "transactions_cursor": "cursor-1",
    }
    database = MemoryDatabase(item)
    service = FailsOncePlaid()
    service.pages = [{"added": [], "modified": [], "removed": [], "next_cursor": "cursor-2", "has_more": False}]
    coordinator = PlaidCoordinator(SimpleNamespace(db=database), service, box)  # type: ignore[arg-type]
    payload = {"webhook_type": "TRANSACTIONS", "webhook_code": "SYNC_UPDATES_AVAILABLE", "item_id": "plaid-item"}
    with pytest.raises(RuntimeError):
        await coordinator.handle_webhook(payload)
    assert database.webhook_events.documents[0]["status"] == "failed"
    await coordinator.handle_webhook(payload)
    assert database.webhook_events.documents[0]["status"] == "completed"
    assert len(database.webhook_events.documents) == 1
