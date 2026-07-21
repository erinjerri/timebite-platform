# Goal Loop Specification

The Goal Loop is the MVP spine:

```text
Goal Loop -> Execution -> Reflection -> Streak -> Insights
```

The experience should feel like a repeatable daily ritual with minimal cognitive load.

---

## Goal Object

Each Goal contains:

| Field | Purpose |
| --- | --- |
| `GoalID` | Stable unique identifier. |
| `Intent` | Plain-language reason or desired outcome. |
| `Category` | User-facing grouping such as health, work, creative, finance, or custom. |
| `Frequency` | How often the user wants to practice the goal. |
| `Sessions` | Timer-backed execution attempts. |
| `CompletionHistory` | Daily completion records for checkmarks, streaks, and calendar cells. |
| `Reflections` | Lightweight journal entries tied to the goal or a session. |
| `CurrentStreak` | Current continuity count derived from completion history. |
| `LongestStreak` | Best historical continuity count. |
| `WeeklySummary` | Derived weekly rollup and reflection summary. |
| `MonthlySummary` | Derived monthly rollup and reflection summary. |
| `Tags` | Flexible labels for filtering and later insights. |

---

## User Flow

1. User creates or selects a Goal.
2. User sets today's intent.
3. User starts a timer session.
4. User completes, partially completes, skips, or marks a rest day.
5. TimeBite shows a completion checkmark when appropriate.
6. TimeBite offers a short reflection prompt.
7. Streak and monthly calendar update.
8. Dashboard summarizes progress only after the loop has data.

---

## Completion States

| State | Meaning | Streak effect |
| --- | --- | --- |
| `completed` | The user completed the intended session. | Advances streak. |
| `partial` | Some progress happened, but below the goal's completion threshold. | May preserve streak if configured. |
| `skipped` | User intentionally skipped. | Breaks or pauses depending on frequency rules. |
| `rest` | Planned rest day. | Preserves streak. |

---

## Reflection Prompts

Reflection must be optional and quick. Suitable prompts:

- What helped today?
- What got in the way?
- What is one sentence you want to remember?
- Do you want to repeat this tomorrow?

Do not force long-form journaling before the user can move on.

---

## Streak Principles

- Reinforce return, not perfection.
- Show current and longest streak without shame copy.
- Support planned rest days.
- Use completion history as the source of truth.
- Keep streak explanations visible enough that users trust them.

---

## Monthly Completion Calendar

The calendar shows each day as a simple completion cell:

- completed
- partial
- skipped
- rest
- future
- today

The calendar should support tapping a day to view sessions and reflections without turning into a dense analytics report.

---

## Insight Rules

Insights are derived and secondary. They should answer:

- Which goals are gaining rhythm?
- Which days are easiest or hardest?
- What reflection themes repeat?
- What should the user keep tiny next week?

AI-generated insights are future work and require explicit opt-in.
