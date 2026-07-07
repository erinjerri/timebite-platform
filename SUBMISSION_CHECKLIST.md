# TimeBite App Store Submission Checklist

Submission target: July 15, 2026.

## App Store Connect Fields

- App name: TimeBite
- Subtitle: Decide what to do next with your time, goals, and money.
- Primary category: Productivity
- Secondary category: Health & Fitness or Finance
- SKU: Choose an internal stable SKU, for example `timebite-ios-001`.
- Bundle ID: `com.timebite.app`
- Version: `1.0`
- Copyright: Confirm legal owner name before submission.
- Age rating: Complete questionnaire. Expected 4+ if no unrestricted web, mature content, gambling, or user-generated public content is enabled.
- Export compliance: Answer based on Apple standard encryption only unless custom cryptography is added.
- Content rights: Confirm TimeBite owns or has rights to included text, icons, and assets.
- Privacy policy URL: Required before submission.
- Support URL: Required before submission.
- Marketing URL: Optional.

## Privacy Labels

Use `PRIVACY_LABELS.md` as the source of truth.

- Health and Fitness: optional, app functionality, not tracking.
- Financial Info: collected on device only for app functionality, not tracking.
- User Content: collected on device only for app functionality, not tracking.
- Usage Data: collected on device only for app functionality, not tracking.
- Contact Info, Identifiers, Diagnostics: not collected in the MVP navigation unless production services are added before submission.

## Review Notes

- MVP navigation: Actions, Goals, Finance, Track, Settings.
- Coming Soon gated features: Vision Board, Studio, Library, Quotes.
- AI/agent features: not active in MVP primary navigation; admin-only local tooling is hidden behind founder unlock.
- Network behavior: quarterly goal chart shows an empty state if the rollup service is unavailable.
- HealthKit behavior: app should continue to function if Health permission is denied.
- Demo account: not required if no authentication is present in the submitted build.
- If authentication is added before submission, provide username, password, and any required setup steps here.

## Binary Readiness

- Confirm app icon renders in all required App Store and device contexts.
- Confirm launch screen displays a dark TimeBite-compatible background without blank white flash.
- Confirm purpose strings exist for HealthKit, microphone, and speech recognition.
- Confirm no placeholder, lorem ipsum, dead buttons, or mock-data labels are reachable from MVP navigation.
- Confirm no hidden data collection or external AI calls are reachable from MVP navigation.
- Confirm notification permission prompts are tied to user-visible reminder features.
