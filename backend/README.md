# Backend (prototype services)

This folder contains early backend/service prototypes (currently Python) for:
- cycles and scoring
- planner parsing/mapping
- constrained assistant routing
- retrieval/ingestion utilities
- telemetry logging

Notes:
- The iPhone MVP is designed to be **local-first**; these services are optional and may remain research-only until sync/integrations require them.
- Treat this folder as a sandbox unless/until a production deployment path is defined (packaging, tests, CI, auth, storage).

Current structure:
```text
backend/
└── services/
    ├── assistant/
    ├── cycles/
    ├── planner/
    ├── retrieval/
    └── telemetry/
```

