from datetime import datetime, timezone
import unittest

from backend.services.goals.quarterly_rollup import Goal, Task
from backend.services.goals.task_completion_handler import (
    InMemoryAgentActionLogger,
    InMemoryCycleMatrixWriter,
    InMemoryTaskCompletionRepository,
    handle_task_completion,
)


class TaskCompletionHandlerTests(unittest.TestCase):
    def test_completion_updates_cycle_matrix_and_recomputes_rollup(self):
        repository = InMemoryTaskCompletionRepository(
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
                    title="Build",
                    category="work",
                    status="pending",
                    goal_id="goal-1",
                    time_allotted_minutes=60,
                )
            ],
        )
        cycle_matrix = InMemoryCycleMatrixWriter()
        logger = InMemoryAgentActionLogger()

        rollup = handle_task_completion(
            user_id="user-1",
            task_id="task-1",
            time_spent_minutes=45,
            repository=repository,
            cycle_matrix=cycle_matrix,
            logger=logger,
            completed_at=datetime(2026, 7, 1, 13, 30, tzinfo=timezone.utc),
        )

        self.assertEqual(repository.tasks[0].completed_at.isoformat(), "2026-07-01T13:30:00+00:00")
        self.assertEqual(repository.tasks[0].time_spent_minutes, 45)
        self.assertEqual(cycle_matrix.increments[0]["row"], "afternoon")
        self.assertEqual(cycle_matrix.increments[0]["column"], "work")
        self.assertEqual(cycle_matrix.increments[0]["value"], 45)
        self.assertEqual(rollup["goals"][0]["logged_minutes"], 45)
        self.assertEqual(logger.events[0]["tagged_by"], "system")
        self.assertTrue(logger.events[0]["rollup_recomputed"])

    def test_completion_without_time_spent_falls_back_to_allotted(self):
        repository = InMemoryTaskCompletionRepository(
            goals=[
                Goal(
                    goal_id="goal-1",
                    user_id="user-1",
                    title="Launch",
                    pillar="admin",
                    quarter="2026-Q3",
                    target_minutes=100,
                    status="active",
                )
            ],
            tasks=[
                Task(
                    task_id="task-1",
                    user_id="user-1",
                    title="Plan",
                    category="admin",
                    status="pending",
                    goal_id="goal-1",
                    time_allotted_minutes=30,
                )
            ],
        )
        cycle_matrix = InMemoryCycleMatrixWriter()
        logger = InMemoryAgentActionLogger()

        rollup = handle_task_completion(
            user_id="user-1",
            task_id="task-1",
            time_spent_minutes=None,
            repository=repository,
            cycle_matrix=cycle_matrix,
            logger=logger,
            completed_at=datetime(2026, 7, 1, 9, 0, tzinfo=timezone.utc),
        )

        self.assertEqual(cycle_matrix.increments[0]["row"], "morning")
        self.assertEqual(cycle_matrix.increments[0]["column"], "admin")
        self.assertEqual(cycle_matrix.increments[0]["value"], 30)
        self.assertEqual(rollup["goals"][0]["logged_minutes"], 30)

    def test_completion_rejects_client_submitted_percent_complete(self):
        task = Task(
            task_id="task-1",
            user_id="user-1",
            title="Build",
            category="work",
            status="pending",
            goal_id="goal-1",
            time_allotted_minutes=60,
        )
        task.percent_complete = 0.9
        repository = InMemoryTaskCompletionRepository(
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
            tasks=[task],
        )

        with self.assertRaises(ValueError):
            handle_task_completion(
                user_id="user-1",
                task_id="task-1",
                time_spent_minutes=45,
                repository=repository,
                cycle_matrix=InMemoryCycleMatrixWriter(),
                logger=InMemoryAgentActionLogger(),
                completed_at=datetime(2026, 7, 1, 13, 30, tzinfo=timezone.utc),
            )

    def test_time_segment_boundaries(self):
        repository = InMemoryTaskCompletionRepository(
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
                Task("t1", "user-1", "Early", "work", "pending", 10, goal_id="goal-1"),
                Task("t2", "user-1", "Noon", "work", "pending", 10, goal_id="goal-1"),
                Task("t3", "user-1", "Evening", "work", "pending", 10, goal_id="goal-1"),
                Task("t4", "user-1", "Night", "work", "pending", 10, goal_id="goal-1"),
            ],
        )
        cycle_matrix = InMemoryCycleMatrixWriter()
        logger = InMemoryAgentActionLogger()

        for task_id, completed_at in [
            ("t1", datetime(2026, 7, 1, 5, 0, tzinfo=timezone.utc)),
            ("t2", datetime(2026, 7, 1, 12, 0, tzinfo=timezone.utc)),
            ("t3", datetime(2026, 7, 1, 17, 0, tzinfo=timezone.utc)),
            ("t4", datetime(2026, 7, 1, 22, 0, tzinfo=timezone.utc)),
        ]:
            handle_task_completion(
                user_id="user-1",
                task_id=task_id,
                time_spent_minutes=None,
                repository=repository,
                cycle_matrix=cycle_matrix,
                logger=logger,
                completed_at=completed_at,
            )

        self.assertEqual(
            [increment["row"] for increment in cycle_matrix.increments],
            ["morning", "afternoon", "evening", "overnight"],
        )


if __name__ == "__main__":
    unittest.main()
