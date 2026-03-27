# TimeBite — Post-Hackathon To-Do List

| Status | Task | Notes |
|--------|------|------|

## 🟢 Phase 1 — Core System Stabilization

| ⬜ | Finalize Cycle Matrix schema | rows (time), columns (categories), values (allocation) |
| ⬜ | Implement cycle_engine update loop | timer → matrix → UI |
| ⬜ | Validate category allocation logic | ensure no overflow / broken states |
| ⬜ | Define Cycle Score v1 | simple heuristic: balance + consistency |
| ⬜ | Add snapshot system | daily state capture |

---

## 🔵 Phase 2 — Cycles Dashboard (Moat UI)

| ⬜ | Build CyclesDashboardView | main entry point |
| ⬜ | Implement category rows + bars | % allocation per cycle |
| ⬜ | Add ring visualization | real-time depletion |
| ⬜ | Add Contribution Grid (v1) | GitHub-style daily history |
| ⬜ | Add Cycle Score card | visible feedback |
| ⬜ | Add Reality Check panel | “what actually happened” |

---

## 🟣 Phase 3 — Data + Persistence

| ⬜ | Implement SwiftData store | local persistence |
| ⬜ | Handle session recovery | restore timers + cycles |
| ⬜ | Add basic backend sync (optional) | minimal API |
| ⬜ | Validate offline-first behavior | app must work without backend |

---

## 🟡 Phase 4 — Constrained Assistant (Tight RAG)

| ⬜ | Implement intent classifier | ui_action / doc_lookup / unsupported |
| ⬜ | Define UI action whitelist | strict allowed actions |
| ⬜ | Build assistant orchestrator | route requests |
| ⬜ | Add documentation retrieval | simple RAG |
| ⬜ | Create Assistant UI panel | not chat-first, suggestion-driven |
| ⬜ | Add fallback responses | explain limitations clearly |

---

## 🔴 Phase 5 — TestFlight Build

| ⬜ | Ensure core loop works | start task → update cycles |
| ⬜ | Remove crashes + edge cases | stability pass |
| ⬜ | Clean navigation flow | no dead ends |
| ⬜ | Add minimal onboarding | first cycle <60s |
| ⬜ | Upload TestFlight build | internal testers |

---

## 🟠 Phase 6 — Apple Positioning

| ⬜ | Create 1-page product summary | cycle-based system |
| ⬜ | Record demo video (30–60s) | show cycles clearly |
| ⬜ | Prepare talking points | differentiation vs trackers |
| ⬜ | Book Apple dev sessions | visionOS + design |

---

## 🟤 Phase 7 — Early Users

| ⬜ | Recruit 20–50 testers | LinkedIn + Substack |
| ⬜ | Track activation rate | first cycle completed |
| ⬜ | Track daily usage | retention |
| ⬜ | Identify friction points | UX gaps |

---

## ⚫ Phase 8 — First Revenue

| ⬜ | Add paywall (simple) | $5–10/month |
| ⬜ | Enable subscription flow | basic billing |
| ⬜ | Convert first users | 20–50 target |
| ⬜ | Gather testimonials | qualitative proof |

---

## 🧠 Guiding Rules

| Rule | Description |
|------|------------|
| 🚫 Don’t overbuild | ship minimal working system |
| 🚫 Don’t chase aesthetics | function > polish |
| ✅ Show reality | core value = truth of time |
| ✅ Prioritize loop | tracking → visualization → feedback |