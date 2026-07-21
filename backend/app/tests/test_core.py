from __future__ import annotations

import base64
from datetime import UTC, datetime
from types import SimpleNamespace

import pytest

from backend.app.config import Environment, Settings
from backend.app.errors import APIError
from backend.app.plaid import money_to_minor
from backend.app.repositories import MongoStore
from backend.app.security import SecretBox, TokenService


def settings(**overrides: object) -> Settings:
    values = {
        "environment": Environment.test,
        "mongo_uri": "mongodb://example.invalid",
        "apple_client_id": "com.timebite.app",
        "jwt_signing_key": "x" * 48,
        "token_encryption_key": base64.urlsafe_b64encode(b"k" * 32).decode(),
        "public_base_url": "http://api.test",
        "plaid_environment": "sandbox",
    }
    values.update(overrides)
    return Settings(**values)


def test_money_is_exact_minor_units() -> None:
    assert money_to_minor("10.015", "USD") == 1002
    assert money_to_minor(12.34, "USD") == 1234
    assert money_to_minor("125", "JPY") == 125


def test_secret_box_round_trip_and_random_nonce() -> None:
    box = SecretBox(settings().token_encryption_key.get_secret_value())
    first = box.encrypt("access-sandbox-token")
    second = box.encrypt("access-sandbox-token")
    assert first != second
    assert box.decrypt(first) == "access-sandbox-token"
    assert "access-sandbox-token" not in first


def test_access_tokens_are_scoped_and_expiring() -> None:
    service = TokenService(settings())
    token, seconds = service.issue_access("stable-user-id")
    assert seconds == 900
    assert service.verify_access(token) == "stable-user-id"


def test_production_rejects_localhost_and_non_https() -> None:
    with pytest.raises(ValueError):
        settings(environment=Environment.production, public_base_url="http://localhost:8000")


class FakeCollection:
    def __init__(self, documents: list[dict]) -> None:
        self.documents = documents
        self.last_filter: dict | None = None

    async def find_one(self, query: dict) -> dict | None:
        self.last_filter = query
        def matches(item: dict) -> bool:
            for key, value in query.items():
                if isinstance(value, dict) and "$exists" in value:
                    if (key in item) != value["$exists"]:
                        return False
                elif item.get(key) != value:
                    return False
            return True
        return next((item for item in self.documents if matches(item)), None)


class FakeDatabase:
    def __init__(self, collection: FakeCollection) -> None:
        self.goals = collection

    def __getitem__(self, name: str) -> FakeCollection:
        return getattr(self, name)


@pytest.mark.asyncio
async def test_user_a_cannot_read_user_b_record() -> None:
    now = datetime.now(UTC)
    collection = FakeCollection([
        {"id": "same-id", "user_id": "user-b", "title": "private", "created_at": now, "updated_at": now}
    ])
    store = MongoStore(FakeDatabase(collection))  # type: ignore[arg-type]
    with pytest.raises(APIError) as captured:
        await store.get_owned("goals", "user-a", "same-id")
    assert captured.value.status_code == 404
    assert collection.last_filter == {"user_id": "user-a", "id": "same-id", "deleted_at": {"$exists": False}}


@pytest.mark.asyncio
async def test_user_b_can_read_own_record() -> None:
    now = datetime.now(UTC)
    collection = FakeCollection([
        {"id": "same-id", "user_id": "user-b", "title": "private", "created_at": now, "updated_at": now}
    ])
    store = MongoStore(FakeDatabase(collection))  # type: ignore[arg-type]
    item = await store.get_owned("goals", "user-b", "same-id")
    assert item["title"] == "private"
