"""Server-owned P7 rollups for Tasks, Work Labels, Goals, and HealthKit.

Clients render these payloads and must never recompute canonical percentages.
Work Labels are user-defined project tags; Goal life areas are a separate
personal taxonomy and intentionally use different fields.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from typing import Iterable

from backend.services.goals.quarterly_rollup import Goal, Task, logged_minutes_for_task


HEALTHKIT_TAGGED_BY = "healthkit_bridge"


@dataclass(frozen=True)
class WorkLabel:
    label_id: str
    user_id: str
    name: str
    color_token: str


def compute_task_state(task: Task) -> dict:
    """Return elapsed and percent complete from canonical task state."""

    elapsed = max(task.time_spent_minutes or 0, 0)
    percent_complete = 0.0
    if task.time_allotted_minutes > 0:
        percent_complete = min(1.0, elapsed / task.time_allotted_minutes)

    return {
        "task_id": task.task_id,
        "estimated_duration_minutes": task.time_allotted_minutes,
        "elapsed_minutes": elapsed,
        "percent_complete": percent_complete,
        "label_id": task.label_id,
    }


def compute_daily_time_by_label(
    user_id: str,
    day: date,
    tasks: Iterable[Task],
    labels: Iterable[WorkLabel],
) -> dict:
    """Aggregate logged task time by user-defined Work Label for one day."""

    user_labels = {label.label_id: label for label in labels if label.user_id == user_id}
    totals = {label_id: 0 for label_id in user_labels}

    for task in tasks:
        if task.user_id != user_id or task.label_id not in user_labels:
            continue
        if task.completed_at is None or task.completed_at.date() != day:
            continue
        totals[task.label_id] += max(logged_minutes_for_task(task), 0)

    maximum = max(totals.values(), default=0)
    return {
        "date": day.isoformat(),
        "labels": [
            {
                "label_id": label.label_id,
                "name": label.name,
                "color_token": label.color_token,
                "minutes": totals[label.label_id],
                "relative_fill": totals[label.label_id] / maximum if maximum else 0.0,
            }
            for label in user_labels.values()
        ],
    }


def compute_goal_state(goal: Goal, tasks: Iterable[Task]) -> dict:
    """Compute canonical goal progress and return P7 deadline fields."""

    child_tasks = [task for task in tasks if task.goal_id == goal.goal_id]
    logged_minutes = sum(
        logged_minutes_for_task(task)
        for task in child_tasks
        if task.completed_at is not None or task.status.lower() in {"complete", "completed"}
    )
    percent_complete = 0.0
    if goal.target_minutes > 0:
        percent_complete = min(1.0, logged_minutes / goal.target_minutes)

    deadline: date | datetime | None = goal.target_date
    return {
        "goal_id": goal.goal_id,
        "life_area": goal.life_area,
        "dependencies_blockers_resources": goal.dependencies_blockers_resources,
        "deadline": deadline.isoformat() if deadline else None,
        "deadline_includes_time": goal.deadline_includes_time,
        "logged_minutes": logged_minutes,
        "percent_complete": percent_complete,
    }


def healthkit_goal_progress_event(
    goal: Goal,
    active_minutes: int,
    steps: int,
    recorded_at: datetime,
) -> dict:
    """Build an auditable read-only HealthKit ingestion event.

    HealthKit may only affect Fitness/Health goals and never creates Tasks.
    """

    if goal.life_area.strip().lower() not in {"fitness/health", "fitness", "health"}:
        raise ValueError("HealthKit can only update Fitness/Health goals")

    return {
        "event_type": "healthkit_goal_progress_ingested",
        "tagged_by": HEALTHKIT_TAGGED_BY,
        "goal_id": goal.goal_id,
        "life_area": goal.life_area,
        "active_minutes": max(active_minutes, 0),
        "steps": max(steps, 0),
        "recorded_at": recorded_at.isoformat(),
        "writes_task_service": False,
    }
