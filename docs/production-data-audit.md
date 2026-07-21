# Production data architecture audit

Audit date: July 21, 2026. The audit preserved the pre-existing modified Xcode project, Finance unlock work, Goals work, Action time-map work, model edits, and theme edits.

## iOS persistence and runtime state

The compiled app target previously registered these SwiftData models: `Goal`, `Milestone`, `GoalProgressEntry`, `AgentSession`, `AIWorkSummary`, `GoalImpact`, `DailyAIReflection`, `FinancialGoal`, `CapitalAllocation`, and `DebtAccount`. A second, older local-first tree under `apps/iOS/Models` has `DailyPlan`, `FocusLane`, `CycleLog`, and `Reflection` plus `TimeBiteModelContainer`, but those files are not members of the active Xcode target. The active app now also registers pending mutations, a sync checkpoint, cached actions/sessions/accounts/transactions, and retains all prior models so the existing store is migrated rather than deleted.

Runtime seed/mock findings:

- Action started with `ActionItem.mock`, four queued sample actions, sample labels, and sample rollups.
- Track started with five mock habits and sample rollups.
- Finance inserted eight demonstration goals and four real-looking debt records whenever its store was empty.
- Goal preview fixtures use an in-memory container and remain preview-only. Other static `GoalItem` and `DailyLog` fixtures remain outside the synchronized personal-data path.

The Action and Track runtime arrays now start empty, mock definitions are DEBUG-only, and Finance no longer seeds. Existing user records are not deleted. A one-time importer queues existing `Goal` records with their stable UUIDs and marks completion in SwiftData rather than UserDefaults.

UserDefaults/AppStorage findings:

- Finance connection booleans were server-worthy and are now derived from `/v1/finance/accounts`.
- The legacy `TimerManager` stores an in-progress session locally, but is not compiled into the active target; sessions are server entities in the new architecture.
- Work-label definitions, custom life areas, notification action handoff, finance-tab open count, and admin UI state are local UI/operational preferences. They do not represent bank connection state.
- The pre-existing founder password in `RootTabView` is not an API secret but should be removed before a public build because client-side gates provide no authorization.

## Backend and URLs

Before this work, Python consisted of standalone assistant, cycles, goals, planner, retrieval, and telemetry modules. Only `backend/services/goals/api.py` optionally exposed a small FastAPI router; there was no application factory, configuration, database lifecycle, authentication, deployment image, or dependency manifest.

The only compiled localhost default was `QuarterlyGoalViewModel`. It now uses the centralized environment URL. Debug explicitly uses loopback; Release has no fallback and requires an HTTPS `TIMEBITE_API_BASE_URL` build setting.

## Capabilities, privacy, tests, and deployment

The target originally had no entitlements file, Sign in with Apple capability, Associated Domains, or package dependencies. It now has the Sign in with Apple entitlement and official Plaid LinkKit Swift package. Associated Domains cannot be finalized until the HTTPS OAuth redirect domain is chosen and its AASA file is hosted.

`PRIVACY_LABELS.md` and `SUBMISSION_CHECKLIST.md` described an on-device-only MVP with no authentication or Finance collection; those statements required replacement for the private beta. Existing automated tests were three Python goal-service suites. There was no iOS test target and no deployment configuration. The new backend includes tests, Docker packaging, pinned dependencies, environment validation, indexes, schema validation, and operational documentation. An iOS test target remains a follow-up because adding a signed target and CI destination is a project-level release decision; Debug and Release device builds are used as the current compile gate.

