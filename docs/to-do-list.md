# TimeBite — Post-hackathon to-do list

Trackable phases after the hackathon. Each table uses **Status** (checkbox), **Task**, and **Notes**.

---

## Phase 1 — Core system stabilization

| Status | Task | Notes |
| ------ | ---- | ----- |
| ⬜ | Finalize Cycle Matrix schema | Rows (time), columns (categories), values (allocation) |
| ⬜ | Implement cycle_engine update loop | Timer → matrix → UI |
| ⬜ | Validate category allocation logic | No overflow / broken states |
| ⬜ | Define Cycle Score v1 | Simple heuristic: balance + consistency |
| ⬜ | Add snapshot system | Daily state capture |

---

## Phase 2 — Cycles dashboard (moat UI)

| Status | Task | Notes |
| ------ | ---- | ----- |
| ⬜ | Build CyclesDashboardView | Main entry point |
| ⬜ | Implement category rows + bars | % allocation per cycle |
| ⬜ | Add ring visualization | Real-time depletion |
| ⬜ | Add Contribution Grid (v1) | GitHub-style daily history |
| ⬜ | Add Cycle Score card | Visible feedback |
| ⬜ | Add Reality Check panel | “What actually happened” |

---

## Phase 3 — Data + persistence

| Status | Task | Notes |
| ------ | ---- | ----- |
| ⬜ | Implement SwiftData store | Local persistence |
| ⬜ | Handle session recovery | Restore timers + cycles |
| ⬜ | Add basic backend sync (optional) | Minimal API |
| ⬜ | Validate offline-first behavior | App works without backend |

---

## Phase 4 — Constrained assistant (tight RAG)

| Status | Task | Notes |
| ------ | ---- | ----- |
| ⬜ | Implement intent classifier | ui_action / doc_lookup / unsupported |
| ⬜ | Define UI action whitelist | Strict allowed actions |
| ⬜ | Build assistant orchestrator | Route requests |
| ⬜ | Add documentation retrieval | Simple RAG |
| ⬜ | Create Assistant UI panel | Not chat-first; suggestion-driven |
| ⬜ | Add fallback responses | Explain limitations clearly |

---

## Phase 5 — TestFlight build

| Status | Task | Notes |
| ------ | ---- | ----- |
| ⬜ | Ensure core loop works | Start task → update cycles |
| ⬜ | Remove crashes + edge cases | Stability pass |
| ⬜ | Clean navigation flow | No dead ends |
| ⬜ | Add minimal onboarding | First cycle in under 60 seconds |
| ⬜ | Upload TestFlight build | Internal testers |

---

## Phase 6 — Apple positioning

| Status | Task | Notes |
| ------ | ---- | ----- |
| ⬜ | Create 1-page product summary | Cycle-based system |
| ⬜ | Record demo video (30–60s) | Show cycles clearly |
| ⬜ | Prepare talking points | Differentiation vs trackers |
| ⬜ | Book Apple dev sessions | visionOS + design |

---

## Phase 7 — Early users

| Status | Task | Notes |
| ------ | ---- | ----- |
| ⬜ | Recruit 20–50 testers | LinkedIn + Substack |
| ⬜ | Track activation rate | First cycle completed |
| ⬜ | Track daily usage | Retention |
| ⬜ | Identify friction points | UX gaps |

---

## Phase 8 — First revenue

| Status | Task | Notes |
| ------ | ---- | ----- |
| ⬜ | Add paywall (simple) | $5–10/month |
| ⬜ | Enable subscription flow | Basic billing |
| ⬜ | Convert first users | 20–50 target |
| ⬜ | Gather testimonials | Qualitative proof |

---

## Guiding rules

| Rule | Description |
| ---- | ----------- |
| Don’t overbuild | Ship minimal working system |
| Don’t chase aesthetics | Function over polish |
| Show reality | Core value = truth of time |
| Prioritize loop | Tracking → visualization → feedback |
