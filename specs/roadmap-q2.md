# Roadmap — Q2 2026 (Apr–Jun)

Time zone: America/Los_Angeles  
Q2 2026 runs **April 1, 2026 → June 30, 2026**.

This roadmap assumes:
- iPhone launch first
- local-first core loop before any backend sync
- capture + AI assistance staged after the loop works end-to-end

## Milestone framing

### M0 — Foundations (Apr)
Goal: lock the canonical day model + timer truth loop.

Deliverables:
- Canonical entities: day plan, lanes, tasks, session logs, reflection
- Ring timer + durable session logging
- Dashboard today view driven by session logs

### M1 — MVP loop (May)
Goal: Daily Intent → Timer → Reflection → Dashboard is cohesive and fast.

Deliverables:
- Daily Intent planner (commit flow)
- Focus lanes UI (3–4 lanes, primary task per lane)
- Reflection UX + history entry point
- Week aggregation (simple)

### M2 — Beta polish + learn (Jun)
Goal: stability, onboarding, and measuring outcomes for an App Store release.

Deliverables:
- Onboarding that creates the first day plan
- Analytics event taxonomy + lightweight dashboards (local or remote)
- Bug bash + crash-free improvements
- App Store assets + review notes

## Suggested week-by-week (starter)

### Week of Apr 20, 2026
- Implement local data model + migrations plan
- Implement timer session persistence + recovery

### Week of Apr 27, 2026
- Dashboard Today view: target vs actual per lane
- Basic task CRUD scoped to day plan

### Weeks of May 4 + May 11, 2026
- Daily Intent commit flow
- Focus lanes “primary task” UX
- Reflection entry + display

### Weeks of May 18 + May 25, 2026
- Week review aggregation
- Polish: performance, empty states, accessibility

### Weeks of Jun 1 + Jun 8, 2026
- Onboarding + first-run success funnel
- Instrumentation + metrics review loop

### Weeks of Jun 15 + Jun 22, 2026
- App Store readiness: screenshots, privacy nutrition label inputs, review notes
- Final QA + release candidate

## Explicit de-scopes for Q2 (unless critical)
- Multi-device sync
- Deep integrations (Notion/Calendar/Sunsama)
- Advanced AI agent autonomy (keep AI as optional suggestions)
- visionOS “hero torus” experience (research only)

