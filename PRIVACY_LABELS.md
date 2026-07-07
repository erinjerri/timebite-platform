# TimeBite Privacy Nutrition Labels

Submission target: iOS MVP review build for July 15, 2026.

## Data Collected

| Data Type | Collected | Purpose | Linked to User | Used for Tracking |
| --- | --- | --- | --- | --- |
| Contact Info | No | Not collected in MVP navigation. | No | No |
| Health and Fitness | Optional | Connect activity or recovery minutes with Track summaries when Health permission is granted. | No backend account in MVP. | No |
| Financial Info | On device only | Store bills, balances, payment reminders, and personal finance goal progress locally. | No backend account in MVP. | No |
| User Content | On device only | Store goals, tasks, notes, reflections, and quarterly target data locally. | No backend account in MVP. | No |
| Identifiers | No | Not collected in MVP navigation. | No | No |
| Usage Data | On device only | Maintain local streaks, completion counts, XP, and progress charts. | No backend account in MVP. | No |
| Diagnostics | No | No production diagnostics collector is active in the MVP navigation. | No | No |

## Permissions

- HealthKit: optional. The app must continue functioning if Health permission is denied.
- Microphone: optional. Used only when the user chooses voice capture for a task or reflection.
- Speech Recognition: optional. Used only to transcribe dictated task or reflection text.
- Notifications: optional. Used only for user-facing reminders such as finance and task follow-ups.

## AI And External APIs

No external AI model calls are active from the MVP primary navigation. AI/agent model objects remain in the codebase for future gated features, but entry points are hidden behind Settings -> Coming Soon or admin-only development access.

Future AI features must disclose what content is sent, why it is sent, who processes it, and require explicit user action before transmission.
