from datetime import datetime, timezone
import unittest

from backend.services.goals.quarterly_rollup import (
    Goal,
    InMemoryGoalTaskRepository,
    Task,
    compute_quarterly_rollup,
)


class QuarterlyRollupTests(unittest.TestCase):
    def test_goal_with_no_tasks_returns_zero_progress(self):
        repository = InMemoryGoalTaskRepository(
            goals=[
                Goal(
                    goal_id="goal-1",
                    user_id="user-1",
                    title="Launch",
                    pillar="work",
                    quarter="2026-Q3",
                    target_minutes=600,
                    status="active",
                )
            ]
        )

        payload = compute_quarterly_rollup("user-1", "2026-Q3", repository)

        self.assertEqual(payload["quarter"], "2026-Q3")
        self.assertEqual(payload["goals"][0]["logged_minutes"], 0)
        self.assertEqual(payload["goals"][0]["percent_complete"], 0)
        self.assertEqual(payload["goals"][0]["task_count"], 0)
        self.assertEqual(payload["goals"][0]["completed_task_count"], 0)

    def test_mixed_complete_and_incomplete_tasks_only_log_completed(self):
        repository = InMemoryGoalTaskRepository(
            goals=[
                Goal(
                    goal_id="goal-1",
                    user_id="user-1",
                    title="Launch",
                    pillar="work",
                    quarter="2026-Q3",
                    target_minutes=120,
                    status="active",
                )
            ],
            tasks=[
                Task(
                    task_id="task-1",
                    user_id="user-1",
                    title="Done",
                    category="work",
                    status="complete",
                    goal_id="goal-1",
                    time_allotted_minutes=45,
                    completed_at=datetime(2026, 7, 1, tzinfo=timezone.utc),
                ),
                Task(
                    task_id="task-2",
                    user_id="user-1",
                    title="Not done",
                    category="work",
                    status="pending",
                    goal_id="goal-1",
                    time_allotted_minutes=60,
                ),
            ],
        )

        payload = compute_quarterly_rollup("user-1", "2026-Q3", repository)

        self.assertEqual(payload["goals"][0]["logged_minutes"], 45)
        self.assertEqual(payload["goals"][0]["task_count"], 2)
        self.assertEqual(payload["goals"][0]["completed_task_count"], 1)
        self.assertEqual(payload["goals"][0]["percent_complete"], 0.375)

    def test_time_spent_overrides_time_allotted_for_completed_tasks(self):
        repository = InMemoryGoalTaskRepository(
            goals=[
                Goal(
                    goal_id="goal-1",
                    user_id="user-1",
                    title="Launch",
                    pillar="work",
                    quarter="2026-Q3",
                    target_minutes=100,
                    status="active",
                )
            ],
            tasks=[
                Task(
                    task_id="task-1",
                    user_id="user-1",
                    title="Done",
                    category="work",
                    status="complete",
                    goal_id="goal-1",
                    time_allotted_minutes=60,
                    time_spent_minutes=25,
                    completed_at=datetime(2026, 7, 1, tzinfo=timezone.utc),
                )
            ],
        )

        payload = compute_quarterly_rollup("user-1", "2026-Q3", repository)

        self.assertEqual(payload["goals"][0]["logged_minutes"], 25)
        self.assertEqual(payload["goals"][0]["percent_complete"], 0.25)

    def test_quarter_boundary_returns_only_goals_for_requested_quarter(self):
        repository = InMemoryGoalTaskRepository(
            goals=[
                Goal(
                    goal_id="q3-goal",
                    user_id="user-1",
                    title="Q3",
                    pillar="work",
                    quarter="2026-Q3",
                    target_minutes=100,
                    status="active",
                ),
                Goal(
                    goal_id="q4-goal",
                    user_id="user-1",
                    title="Q4",
                    pillar="personal",
                    quarter="2026-Q4",
                    target_minutes=100,
                    status="active",
                ),
            ],
            tasks=[
                Task(
                    task_id="task-1",
                    user_id="user-1",
                    title="Last Q3 minute",
                    category="work",
                    status="complete",
                    goal_id="q3-goal",
                    time_allotted_minutes=30,
                    completed_at=datetime(2026, 9, 30, 23, 59, tzinfo=timezone.utc),
                ),
                Task(
                    task_id="task-2",
                    user_id="user-1",
                    title="First Q4 minute",
                    category="personal",
                    status="complete",
                    goal_id="q4-goal",
                    time_allotted_minutes=40,
                    completed_at=datetime(2026, 10, 1, 0, 0, tzinfo=timezone.utc),
                ),
            ],
        )

        q3_payload = compute_quarterly_rollup("user-1", "2026-Q3", repository)
        q4_payload = compute_quarterly_rollup("user-1", "2026-Q4", repository)

        self.assertEqual([goal["goal_id"] for goal in q3_payload["goals"]], ["q3-goal"])
        self.assertEqual(q3_payload["goals"][0]["logged_minutes"], 30)
        self.assertEqual([goal["goal_id"] for goal in q4_payload["goals"]], ["q4-goal"])
        self.assertEqual(q4_payload["goals"][0]["logged_minutes"], 40)


if __name__ == "__main__":
    unittest.main()
