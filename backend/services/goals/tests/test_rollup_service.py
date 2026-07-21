import unittest
from datetime import date, datetime, timezone

from backend.services.goals.quarterly_rollup import Goal, Task
from backend.services.goals.rollup_service import (
    WorkLabel,
    compute_daily_time_by_label,
    compute_goal_state,
    compute_task_state,
    healthkit_goal_progress_event,
)


class P7RollupServiceTests(unittest.TestCase):
    def test_task_percent_is_server_computed(self):
        task = Task("t1", "u1", "Build", "work", "running", 40, time_spent_minutes=10)
        self.assertEqual(compute_task_state(task)["percent_complete"], 0.25)

    def test_daily_rollup_groups_by_user_label(self):
        completed_at = datetime(2026, 7, 18, 12, tzinfo=timezone.utc)
        labels = [WorkLabel("product", "u1", "#product", "mint")]
        tasks = [
            Task("t1", "u1", "Build", "work", "complete", 30, label_id="product", time_spent_minutes=22, completed_at=completed_at),
            Task("t2", "u1", "Review", "work", "complete", 15, label_id="product", time_spent_minutes=8, completed_at=completed_at),
        ]

        payload = compute_daily_time_by_label("u1", date(2026, 7, 18), tasks, labels)
        self.assertEqual(payload["labels"][0]["minutes"], 30)
        self.assertEqual(payload["labels"][0]["relative_fill"], 1.0)

    def test_goal_state_uses_life_area_and_server_progress(self):
        goal = Goal("g1", "u1", "Walk daily", "Health", "2026-Q3", 100, "active", life_area="Fitness/Health")
        tasks = [Task("t1", "u1", "Walk", "health", "complete", 30, goal_id="g1", time_spent_minutes=25)]
        payload = compute_goal_state(goal, tasks)
        self.assertEqual(payload["life_area"], "Fitness/Health")
        self.assertEqual(payload["percent_complete"], 0.25)

    def test_healthkit_is_restricted_and_audited(self):
        fitness = Goal("g1", "u1", "Walk daily", "Health", "2026-Q3", 100, "active", life_area="Fitness/Health")
        event = healthkit_goal_progress_event(fitness, 30, 8000, datetime.now(timezone.utc))
        self.assertEqual(event["tagged_by"], "healthkit_bridge")
        self.assertFalse(event["writes_task_service"])

        work = Goal("g2", "u1", "Ship", "Work", "2026-Q3", 100, "active", life_area="Work")
        with self.assertRaises(ValueError):
            healthkit_goal_progress_event(work, 30, 8000, datetime.now(timezone.utc))


if __name__ == "__main__":
    unittest.main()
