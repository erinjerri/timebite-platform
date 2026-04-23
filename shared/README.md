# Shared

Shared code and schemas intended to be reused across platform apps and services.

Near-term:
- canonical JSON schemas in `schemas/`
- shared product constants (lane names, tokens)

Future:
- shared Swift packages for UI + domain logic
- shared protocol definitions for sync and integrations

Current:
- `shared/TimeBiteDomain/` — starter Swift package with SwiftData models for Projects + Sessions + Weekly Caps aggregation (not yet wired into an Xcode app)
