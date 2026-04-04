# System architecture

High-level flow for the TimeBite platform: ingestion, canonical tasks, integrations, agents, UI surfaces, and telemetry.

---

## Information architecture

```mermaid
flowchart TD
    User["User"] --> Manual["Manual Text"]
    User --> Voice["Voice / STT"]
    User --> Vision["Vision Capture"]

    Health["HealthKit"] --> Canonical
    Sunsama["Sunsama Adapter"] --> Canonical
    Notion["Notion Adapter"] --> Canonical
    GCal["Google Calendar Adapter"] --> Canonical
    Asana["Asana Adapter"] --> Canonical

    Manual --> Canonical["Canonical Task Layer"]
    Voice --> Canonical
    Vision --> Canonical

    Canonical --> GreenAgent["Green Agent<br/>Planning"]
    Canonical --> PurpleAgent["Purple Agent<br/>Execution"]

    GreenAgent --> PlannerUI["Planner / Daily Intent"]
    PurpleAgent --> ExecutionUI["Execution View + Timers"]
    Canonical --> CyclesUI["Rings / Cycles / Reflection"]

    ExecutionUI --> CycleEngine["Cycle Engine"]
    CycleEngine --> Scoring["Scoring + Snapshots"]
    Scoring --> CyclesUI

    AssistantUI["Constrained Assistant"] --> Orchestrator
    Orchestrator --> IntentClassifier
    IntentClassifier -->|UI action| UIWhitelist["UI Action Whitelist"]
    IntentClassifier -->|Doc lookup| Retriever["Retriever"]
    IntentClassifier -->|Unsupported| Fallback["Fallback"]
    UIWhitelist --> PlannerUI
    UIWhitelist --> ExecutionUI
    Retriever --> Docs["Docs"]
    Docs --> Response["Assistant Response"]
    Fallback --> Response
    Response --> AssistantUI

    Canonical --> Storage[(Canonical Store)]
    Docs --> VectorDB[(Vector Store)]
    Canonical --> Telemetry["Telemetry"]
    Telemetry --> Logs[(JSONL Logs)]

    Canonical -. optional write-back .-> Sunsama
    Canonical -. optional write-back .-> Notion
    Canonical -. optional write-back .-> GCal
    Canonical -. optional write-back .-> Asana
```

---

## Legend

| Symbol | Meaning |
| ------ | ------- |
| **Canonical Task Layer** | Source of truth that normalizes all inputs and integrations |
| **Green / Purple** | Planning vs execution paths that operate on canonical tasks |
| **Adapters** | Integration boundaries for Sunsama, Notion, Calendar, and Asana |
| **Orchestrator** | Routes assistant intents to UI whitelist, retrieval, or fallback |
| **Telemetry** | Structured logs for replay and debugging |

If the diagram does not render, use a viewer that supports [Mermaid](https://mermaid.js.org/) (GitHub renders it in fenced `mermaid` blocks).
