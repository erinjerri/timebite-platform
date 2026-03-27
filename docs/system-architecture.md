flowchart TD

%% USER
User -->|input task / action| App

%% APP LAYER
App[iOS / visionOS / macOS App]

App --> CyclesUI[Cycles Dashboard]
App --> TaskTimer
App --> AssistantUI

%% CORE LOOP
TaskTimer --> CycleMatrix

CycleMatrix --> CycleEngine
CycleEngine --> Scoring
CycleEngine --> Snapshots

CycleMatrix --> CyclesUI

%% UI COMPONENTS
CyclesUI --> Bars[Category Bars]
CyclesUI --> Grid[Contribution Grid]
CyclesUI --> Score[Cycle Score]

%% AGENTS
GreenAgent[Green Agent\nPlanning]
PurpleAgent[Purple Agent\nExecution]

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