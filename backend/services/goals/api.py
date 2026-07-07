"""Read-only goal route adapters.

This module is intentionally small because the repo does not yet have a
backend/api package. The exported router can be mounted by the eventual API
app at GET /goals/quarterly?quarter=2026-Q3.
"""

from __future__ import annotations

from dataclasses import dataclass

from backend.services.goals.quarterly_rollup import (
    GoalTaskRepository,
    compute_quarterly_rollup,
)


@dataclass(frozen=True)
class QuarterlyGoalsRoute:
    repository: GoalTaskRepository

    def get(self, user_id: str, quarter: str) -> dict:
        return compute_quarterly_rollup(user_id, quarter, self.repository)


def get_quarterly_goals(
    user_id: str,
    quarter: str,
    repository: GoalTaskRepository,
) -> dict:
    """Idempotent read-only handler for GET /goals/quarterly."""

    return compute_quarterly_rollup(user_id, quarter, repository)


try:
    from fastapi import APIRouter, Depends, Query
except ImportError:  # pragma: no cover - FastAPI is optional in this repo.
    router = None
else:
    router = APIRouter()

    def get_repository() -> GoalTaskRepository:
        raise RuntimeError("GoalTaskRepository dependency is not configured")

    def get_current_user_id() -> str:
        raise RuntimeError("current user dependency is not configured")

    @router.get("/goals/quarterly")
    def read_quarterly_goals(
        quarter: str = Query(..., pattern=r"^\d{4}-Q[1-4]$"),
        user_id: str = Depends(get_current_user_id),
        repository: GoalTaskRepository = Depends(get_repository),
    ) -> dict:
        return get_quarterly_goals(user_id, quarter, repository)
