# TimeBite Privacy Nutrition Labels

Submission target: iOS MVP review build for July 15, 2026.

## Data Collected

| Data Type | Collected | Purpose | Linked to User | Used for Tracking |
| --- | --- | --- | --- | --- |
| Contact Info | Optional | Apple relay or account email used for authentication and support. | Yes | No |
| Health and Fitness | Optional | Connect activity or recovery minutes with goal summaries when Health permission is granted. | No backend account in MVP. | No |
| Financial Info | Optional | Linked account metadata, balances, and transactions power user-requested Finance features through Plaid. | Yes | No |
| User Content | Yes | Synchronize goals, actions, sessions, finance goals, notes, and progress across devices. | Yes | No |
| Identifiers | Yes | Maintain the private TimeBite account, Apple subject mapping, and security sessions. | Yes | No |
| Usage Data | Yes | Synchronize completion and session state needed for app functionality. | Yes | No |
| Diagnostics | No | No production diagnostics collector is active in the MVP navigation. | No | No |

## Permissions

- HealthKit: optional. The app must continue functioning if Health permission is denied.
- Microphone: optional. Used only when the user chooses voice capture for a task or reflection.
- Speech Recognition: optional. Used only to transcribe dictated task or reflection text.
- Notifications: optional. Used only for user-facing reminders such as daily intent, goal sessions, and reflection follow-ups.

## AI And External APIs

No external AI model calls are active from the beta navigation. The API uses MongoDB Atlas, Sign in with Apple, and Plaid Sandbox. Plaid handles institution credentials; TimeBite never receives them. Plaid access tokens are encrypted by the backend and never returned to iOS.

Future AI features must disclose what content is sent, why it is sent, who processes it, and require explicit user action before transmission.
