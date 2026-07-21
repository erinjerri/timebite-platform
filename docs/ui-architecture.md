# UI Architecture

The iOS MVP should be ritual-first and low-cognitive-load. The primary surface is Today, not an analytics dashboard.

---

## Navigation

| Surface | Role |
| --- | --- |
| Today | Daily intent, active session, completion checkmarks, reflection prompt. |
| Goals | Goal management, frequency, streak state, recent sessions. |
| Calendar | Monthly completion calendar and day detail. |
| Dashboard | Calm summary of streaks, weekly progress, monthly progress, and insights. |
| Settings | Privacy, reminders, export, gated future features. |

---

## Today Surface

Today should answer:

- What matters today?
- What is active now?
- What is complete?
- What is worth remembering?

Expected components:

- Daily intent selector
- Goal row with checkmark state
- Timer control
- Completion action
- Reflection prompt sheet
- Gentle streak reinforcement

---

## Component Principles

- Use checkmarks for completion.
- Use small streak indicators, not loud badges.
- Keep journaling inline or sheet-based.
- Prefer one primary action at a time.
- Avoid showing charts before the user has completed sessions.
- Make empty states actionable and calm.

---

## State Ownership

| UI state | Domain source |
| --- | --- |
| Goal list | Goal store |
| Today's intents | Goal Loop daily intent state |
| Timer | Session model |
| Checkmarks | Completion history |
| Streaks | Derived streak engine |
| Calendar cells | Completion history |
| Reflections | Reflection records |
| Dashboard summaries | Weekly and monthly summary engines |

---

## Visual Direction

TimeBite should feel calm, intentional, and personal. It should not copy any reference product's exact screens, colors, typography, or layout. Extract interaction patterns only: completion, streak reinforcement, quick reflection, month view, and ritual cadence.
