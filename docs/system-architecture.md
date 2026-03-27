# System architecture

High-level flow for the TimeBite client: cycle matrix, UI surfaces, constrained assistant, and telemetry.

---

## Data flow

```mermaid
flowchart TD
    %% USER
    User -->|input task / action| App

    %% APP LAYER
    App["iOS / visionOS / macOS App"]
    App --> CyclesUI["Cycles Dashboard"]
    App --> TaskTimer
    App --> AssistantUI

    %% CORE LOOP
    TaskTimer --> CycleMatrix
    CycleMatrix --> CycleEngine
    CycleEngine --> Scoring
    CycleEngine --> Snapshots
    CycleMatrix --> CyclesUI

    %% UI COMPONENTS
    CyclesUI --> Bars["Category Bars"]
    CyclesUI --> Grid["Contribution Grid"]
    CyclesUI --> Score["Cycle Score"]

    %% AGENTS
    GreenAgent["Green Agent<br/>Planning"]
    PurpleAgent["Purple Agent<br/>Execution"]
    GreenAgent --> CycleMatrix
    PurpleAgent --> CycleMatrix

    %% ASSISTANT (TIGHT RAG)
    AssistantUI --> Orchestrator
    Orchestrator --> IntentClassifier
    IntentClassifier -->|UI Action| UIWhitelist
    IntentClassifier -->|Doc Lookup| Retriever
    IntentClassifier -->|Unsupported| Fallback
    UIWhitelist --> App
    Retriever --> Docs
    Docs --> Response
    Fallback --> Response
    Response --> AssistantUI

    %% DATA
    CycleMatrix --> Storage[(Local + Backend Storage)]
    Docs --> VectorDB[(Vector Store)]

    %% TELEMETRY
    CycleMatrix --> Telemetry
    Telemetry --> Logs[(JSONL Logs)]

    %% OUTPUT
    CycleMatrix --> CyclesUI
```

---

## Legend

| Symbol | Meaning |
| ------ | ------- |
| **Cycle Matrix** | Backend source of truth for time × category allocation |
| **Green / Purple** | Planning vs execution paths into the matrix |
| **Orchestrator** | Routes assistant intents to UI whitelist, retrieval, or fallback |
| **Telemetry** | Structured logs for replay and debugging |

If the diagram does not render, use a viewer that supports [Mermaid](https://mermaid.js.org/) (GitHub renders it in fenced `mermaid` blocks).
