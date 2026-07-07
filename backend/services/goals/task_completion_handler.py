"""Task completion handler for goal progress and Cycle Matrix updates."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Callable, Protocol

from backend.services.goals.quarterly_rollup import (
    Goal,
    GoalTaskRepository,
    Task,
    compute_quarterly_rollup,
    logged_minutes_for_task,
)


SYSTEM_TAGGED_BY = "system"


class TaskCompletionRepository(GoalTaskRepository, Protocol):
    def get_task(self, user_id: str, task_id: str) -> Task:
        ...

    def get_goal(self, user_id: str, goal_id: str) -> Goal:
        ...

    def save_task(self, task: Task) -> None:
        ...


class CycleMatrixWriter(Protocol):
    def increment(self, user_id: str, row: str, column: str, value: int) -> None:
        ...


class AgentActionLogger(Protocol):
    def emit(self, event: dict) -> None:
        ...


@dataclass
class InMemoryTaskCompletionRepository:
    goals: list[Goal] = field(default_factory=list)
    tasks: list[Task] = field(default_factory=list)

    def list_goals(self, user_id: str, quarter: str) -> list[Goal]:
        return [
            goal
            for goal in self.goals
            if goal.user_id == user_id and goal.quarter == quarter
        ]

    def list_tasks_for_goal(self, user_id: str, goal_id: str) -> list[Task]:
        return [
            task
            for task in self.tasks
            if task.user_id == user_id and task.goal_id == goal_id
        ]

    def get_task(self, user_id: str, task_id: str) -> Task:
        for task in self.tasks:
            if task.user_id == user_id and task.task_id == task_id:
                return task
        raise KeyError(f"task not found: {task_id}")

    def get_goal(self, user_id: str, goal_id: str) -> Goal:
        for goal in self.goals:
            if goal.user_id == user_id and goal.goal_id == goal_id:
                return goal
        raise KeyError(f"goal not found: {goal_id}")

    def save_task(self, task: Task) -> None:
        return None


@dataclass
class InMemoryCycleMatrixWriter:
    increments: list[dict] = field(default_factory=list)

    def increment(self, user_id: str, row: str, column: str, value: int) -> None:
        self.increments.append(
            {
                "user_id": user_id,
                "row": row,
                "column": column,
                "value": value,
            }
        )


@dataclass
class InMemoryAgentActionLogger:
    events: list[dict] = field(default_factory=list)

    def emit(self, event: dict) -> None:
        self.events.append(event)


def handle_task_completion(
    user_id: str,
    task_id: str,
    time_spent_minutes: int | None,
    repository: TaskCompletionRepository,
    cycle_matrix: CycleMatrixWriter,
    logger: AgentActionLogger,
    completed_at: datetime | None = None,
    now: Callable[[], datetime] | None = None,
) -> dict | None:
    """Complete a task, update Cycle Matrix, and recompute the parent rollup."""

    completion_time = completed_at or _utc_now(now)
    task = repository.get_task(user_id, task_id)

    _reject_client_progress_fields(task)

    task.status = "complete"
    task.completed_at = completion_time
    task.time_spent_minutes = time_spent_minutes
    repository.save_task(task)

    if task.goal_id is None:
        logger.emit(_audit_event(user_id, task, None, completion_time, None))
        return None

    goal = repository.get_goal(user_id, task.goal_id)
    minutes = logged_minutes_for_task(task)
    cycle_matrix.increment(
        user_id=user_id,
        row=time_segment_for(completion_time),
        column=goal.pillar,
        value=minutes,
    )

    rollup = compute_quarterly_rollup(user_id, goal.quarter, repository)
    logger.emit(_audit_event(user_id, task, goal, completion_time, rollup))
    return rollup


def time_segment_for(completed_at: datetime) -> str:
    hour = completed_at.hour

    if 5 <= hour < 12:
        return "morning"
    if 12 <= hour < 17:
        return "afternoon"
    if 17 <= hour < 22:
        return "evening"
    return "overnight"


def _utc_now(now: Callable[[], datetime] | None) -> datetime:
    if now is not None:
        return now()
    return datetime.now(timezone.utc)


def _reject_client_progress_fields(task: Task) -> None:
    if hasattr(task, "percent_complete"):
        raise ValueError("percent_complete is server-computed and cannot be submitted")


def _audit_event(
    user_id: str,
    task: Task,
    goal: Goal | None,
    completed_at: datetime,
    rollup: dict | None,
) -> dict:
    return {
        "event_type": "task_completion_rollup_recomputed",
        "tagged_by": SYSTEM_TAGGED_BY,
        "user_id": user_id,
        "task_id": task.task_id,
        "goal_id": goal.goal_id if goal else None,
        "quarter": goal.quarter if goal else None,
        "time_spent_minutes": logged_minutes_for_task(task),
        "completed_at": completed_at.isoformat(),
        "rollup_recomputed": rollup is not None,
    }
