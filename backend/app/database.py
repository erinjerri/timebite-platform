from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import Any

from pymongo import ASCENDING, DESCENDING, AsyncMongoClient, IndexModel
from pymongo.asynchronous.database import AsyncDatabase

from backend.app.config import Settings


USER_COLLECTIONS = (
    "goals",
    "actions",
    "sessions",
    "financial_goals",
    "plaid_items",
    "financial_accounts",
    "transactions",
    "consent_records",
)


INDEXES: dict[str, list[IndexModel]] = {
    "users": [IndexModel("apple_subject", unique=True), IndexModel("id", unique=True)],
    "refresh_tokens": [
        IndexModel("token_hash", unique=True),
        IndexModel([("user_id", ASCENDING), ("family_id", ASCENDING)]),
        IndexModel("expires_at", expireAfterSeconds=0),
    ],
    "goals": [IndexModel([("user_id", ASCENDING), ("id", ASCENDING)], unique=True)],
    "actions": [
        IndexModel([("user_id", ASCENDING), ("id", ASCENDING)], unique=True),
        IndexModel([("user_id", ASCENDING), ("goal_id", ASCENDING)]),
    ],
    "sessions": [
        IndexModel([("user_id", ASCENDING), ("id", ASCENDING)], unique=True),
        IndexModel([("user_id", ASCENDING), ("action_id", ASCENDING)]),
    ],
    "financial_goals": [IndexModel([("user_id", ASCENDING), ("id", ASCENDING)], unique=True)],
    "plaid_items": [
        IndexModel([("user_id", ASCENDING), ("id", ASCENDING)], unique=True),
        IndexModel("plaid_item_id", unique=True),
    ],
    "financial_accounts": [
        IndexModel([("user_id", ASCENDING), ("id", ASCENDING)], unique=True),
        IndexModel("plaid_account_id", unique=True),
        IndexModel([("user_id", ASCENDING), ("plaid_item_id", ASCENDING)]),
    ],
    "transactions": [
        IndexModel([("user_id", ASCENDING), ("id", ASCENDING)], unique=True),
        IndexModel("plaid_transaction_id", unique=True),
        IndexModel([("user_id", ASCENDING), ("authorized_date", DESCENDING)]),
    ],
    "webhook_events": [
        IndexModel([("provider", ASCENDING), ("event_id", ASCENDING)], unique=True),
        IndexModel("received_at"),
    ],
    "consent_records": [IndexModel([("user_id", ASCENDING), ("id", ASCENDING)], unique=True)],
    "sync_changes": [
        IndexModel([("user_id", ASCENDING), ("sequence", ASCENDING)], unique=True),
        IndexModel([("user_id", ASCENDING), ("entity_type", ASCENDING), ("entity_id", ASCENDING)]),
    ],
    "counters": [IndexModel("_id", unique=True)],
}


async def initialize_database(db: AsyncDatabase[dict[str, Any]]) -> None:
    for collection_name, indexes in INDEXES.items():
        await db[collection_name].create_indexes(indexes)

    validator = {
        "$jsonSchema": {
            "bsonType": "object",
            "required": ["id", "user_id", "created_at", "updated_at", "schema_version"],
            "properties": {
                "id": {"bsonType": "string"},
                "user_id": {"bsonType": "string"},
                "created_at": {"bsonType": "date"},
                "updated_at": {"bsonType": "date"},
                "schema_version": {"bsonType": "int", "minimum": 1},
            },
        }
    }
    existing = set(await db.list_collection_names())
    for name in USER_COLLECTIONS:
        if name in existing:
            await db.command("collMod", name, validator=validator, validationLevel="moderate")
        else:
            await db.create_collection(name, validator=validator)


@asynccontextmanager
async def mongo_lifespan(settings: Settings) -> AsyncIterator[AsyncDatabase[dict[str, Any]]]:
    client: AsyncMongoClient[dict[str, Any]] = AsyncMongoClient(
        settings.mongo_uri.get_secret_value(),
        appname="timebite-api",
        serverSelectionTimeoutMS=5_000,
        tz_aware=True,
    )
    db = client[settings.mongo_database]
    await db.command("ping")
    await initialize_database(db)
    try:
        yield db
    finally:
        await client.close()
