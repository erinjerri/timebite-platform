# App Store Launch (iOS)

This is a practical checklist + guide for shipping TimeBite to the iOS App Store.

## 1) Apple Developer + App Store Connect setup
- Ensure Apple Developer Program membership is active.
- Create the app record in App Store Connect:
  - bundle id
  - app name
  - SKU
  - primary language

## 2) Product readiness

Minimum bar for first public release:
- Onboarding leads to first successful day plan.
- Timer sessions are durable across backgrounding.
- Dashboard reconciles with session logs.
- Crash-free rate is high enough to be confident in review (goal: > 99%).

## 3) Compliance + privacy

### Privacy policy
- Publish a privacy policy page (even if simple) covering:
  - what data is stored locally
  - what data (if any) is transmitted
  - what analytics is collected (if any)
  - user deletion/export options

### Privacy “nutrition label”
Prepare answers for:
- identifiers collected (if any)
- usage data (events)
- diagnostics (crash logs)
- content (reflection/notes/transcripts) — should be “not collected” by default

### App Tracking Transparency (ATT)
- Avoid ATT entirely unless you do cross-app tracking (recommended: do not).

## 4) App Store assets

### Required
- App icon (all required sizes)
- Screenshots (iPhone; iPad optional if supported)
- App preview video (optional)
- Description:
  - one-line value prop
  - key features
  - privacy stance

### Suggested screenshot narrative
1. “Commit today’s intent”
2. “One lane, one primary task”
3. “Ring timer execution”
4. “Reflection + learnings”
5. “Dashboard truth (target vs actual)”

## 5) Release process

### TestFlight
- Internal testing first.
- External testing once onboarding + timer are stable.
- Collect feedback explicitly on:
  - time-to-first-success (first plan + first timed session)
  - confusion points (lanes, budgets, ring meaning)

### App Review notes
- Explain that the app is local-first.
- If using microphone/camera:
  - state why (voice capture / OCR capture)
  - show where permissions are requested
- If using AI:
  - clarify that suggestions are optional and user-confirmed

### Phased release
- Consider phased release for stability.

## 6) Post-launch (week 1)
- Monitor crash and performance metrics daily.
- Track:
  - activation rate (plan committed + timer started)
  - day-2 and week-1 retention
  - “intent → execution” funnel
- Ship quick bugfix updates; keep scope tight.

