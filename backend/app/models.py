from __future__ import annotations

from datetime import date, datetime
from typing import Any, Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class AppleLoginRequest(StrictModel):
    identity_token: str
    raw_nonce: str = Field(min_length=16, max_length=256)


class RefreshRequest(StrictModel):
    refresh_token: str


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: Literal["bearer"] = "bearer"
    expires_in: int


class EntityWrite(StrictModel):
    id: UUID
    base_updated_at: datetime | None = None
    client_updated_at: datetime
    data: dict[str, Any]


class GoalWrite(StrictModel):
    id: UUID
    title: str = Field(min_length=1, max_length=200)
    details: str = Field(default="", max_length=10_000)
    status: Literal["active", "completed", "archived"] = "active"
    target_date: date | None = None
    base_updated_at: datetime | None = None
    client_updated_at: datetime


class ActionWrite(StrictModel):
    id: UUID
    goal_id: UUID | None = None
    title: str = Field(min_length=1, max_length=300)
    status: Literal["pending", "active", "completed", "cancelled"] = "pending"
    scheduled_at: datetime | None = None
    estimated_minutes: int = Field(default=25, ge=1, le=1440)
    base_updated_at: datetime | None = None
    client_updated_at: datetime


class SessionStart(StrictModel):
    id: UUID
    action_id: UUID | None = None
    started_at: datetime


class FinancialGoalWrite(StrictModel):
    id: UUID
    name: str = Field(min_length=1, max_length=200)
    target_minor_units: int = Field(ge=0)
    current_minor_units: int = Field(default=0, ge=0)
    currency: str = Field(default="USD", min_length=3, max_length=3)
    base_updated_at: datetime | None = None
    client_updated_at: datetime


class SyncPush(StrictModel):
    mutation_id: UUID
    entity_type: Literal["goals", "actions", "sessions", "financial_goals"]
    operation: Literal["upsert", "delete"]
    entity_id: UUID
    base_updated_at: datetime | None = None
    client_updated_at: datetime
    payload: dict[str, Any] = {}


class SyncRequest(StrictModel):
    cursor: int = Field(default=0, ge=0)
    mutations: list[SyncPush] = Field(default_factory=list, max_length=200)


class PlaidExchangeRequest(StrictModel):
    public_token: str


class PlaidWebhook(StrictModel):
    webhook_type: str
    webhook_code: str
    item_id: str | None = None
    environment: str | None = None
    error: dict[str, Any] | None = None

