"""Quarterly goal rollups for the iOS goal chart.

Cycle Matrix remains the source of truth for time allocation. This module
computes the chart payload from completed child tasks and never accepts
client-submitted progress percentages.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date, datetime
from typing import Iterable, Protocol


COMPLETED_STATUSES = {"complete", "completed"}


@dataclass(frozen=True)
class Goal:
    goal_id: str
    user_id: str
    title: str
    pillar: str
    quarter: str
    target_minutes: int
    status: str
    life_area: str = "Work"
    dependencies_blockers_resources: str = ""
    deadline_includes_time: bool = False
    created_at: datetime | None = None
    target_date: date | None = None


@dataclass
class Task:
    task_id: str
    user_id: str
    title: str
    category: str
    status: str
    time_allotted_minutes: int
    goal_id: str | None = None
    label_id: str | None = None
    time_spent_minutes: int | None = None
    completed_at: datetime | None = None


@dataclass(frozen=True)
class GoalRollup:
    goal_id: str
    title: str
    pillar: str
    target_minutes: int
    logged_minutes: int
    percent_complete: float
    task_count: int
    completed_task_count: int

    def to_payload(self) -> dict:
        return {
            "goal_id": self.goal_id,
            "title": self.title,
            "pillar": self.pillar,
            "target_minutes": self.target_minutes,
            "logged_minutes": self.logged_minutes,
            "percent_complete": self.percent_complete,
            "task_count": self.task_count,
            "completed_task_count": self.completed_task_count,
        }


class GoalTaskRepository(Protocol):
    def list_goals(self, user_id: str, quarter: str) -> Iterable[Goal]:
        ...

    def list_tasks_for_goal(self, user_id: str, goal_id: str) -> Iterable[Task]:
        ...


@dataclass
class InMemoryGoalTaskRepository:
    goals: list[Goal] = field(default_factory=list)
    tasks: list[Task] = field(default_factory=list)

    def list_goals(self, user_id: str, quarter: str) -> Iterable[Goal]:
        return [
            goal
            for goal in self.goals
            if goal.user_id == user_id and goal.quarter == quarter
        ]

    def list_tasks_for_goal(self, user_id: str, goal_id: str) -> Iterable[Task]:
        return [
            task
            for task in self.tasks
            if task.user_id == user_id and task.goal_id == goal_id
        ]


def compute_quarterly_rollup(
    user_id: str,
    quarter: str,
    repository: GoalTaskRepository,
) -> dict:
    """Return the server-computed quarterly rollup payload."""

    goals = list(repository.list_goals(user_id, quarter))
    rollups = [
        _compute_goal_rollup(goal, repository.list_tasks_for_goal(user_id, goal.goal_id))
        for goal in goals
    ]

    return {
        "quarter": quarter,
        "goals": [rollup.to_payload() for rollup in rollups],
    }


def _compute_goal_rollup(goal: Goal, tasks: Iterable[Task]) -> GoalRollup:
    child_tasks = list(tasks)
    completed_tasks = [task for task in child_tasks if is_completed(task)]
    logged_minutes = sum(logged_minutes_for_task(task) for task in completed_tasks)
    percent_complete = 0

    if goal.target_minutes > 0:
        percent_complete = min(1, logged_minutes / goal.target_minutes)

    return GoalRollup(
        goal_id=goal.goal_id,
        title=goal.title,
        pillar=goal.pillar,
        target_minutes=goal.target_minutes,
        logged_minutes=logged_minutes,
        percent_complete=percent_complete,
        task_count=len(child_tasks),
        completed_task_count=len(completed_tasks),
    )


def is_completed(task: Task) -> bool:
    return task.status.lower() in COMPLETED_STATUSES or task.completed_at is not None


def logged_minutes_for_task(task: Task) -> int:
    if task.time_spent_minutes is not None:
        return task.time_spent_minutes
    return task.time_allotted_minutes
