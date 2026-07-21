# TimeBite API

FastAPI is the only network boundary between iOS and MongoDB Atlas. The app uses PyMongo's supported `AsyncMongoClient`; it does not use Realm Device Sync, Atlas App Services, or Motor.

## Local development

1. Create a dedicated Atlas development project and least-privilege database user.
2. Copy `backend/.env.example` to an untracked `backend/.env` and populate it locally. Do not commit it or paste values into tickets/chat.
3. Generate `TIMEBITE_JWT_SIGNING_KEY` with `openssl rand -base64 48` and `TIMEBITE_TOKEN_ENCRYPTION_KEY` with `openssl rand -base64 32 | tr '+/' '-_'`. Store production values in the hosting provider's secret manager.
4. Install with `python3 -m venv .venv`, `.venv/bin/pip install -r backend/requirements.lock`.
5. Export variables from your secret manager or local shell, then run `.venv/bin/uvicorn backend.app.main:app --reload`.
6. Run `.venv/bin/pytest`.

The checked-in example contains variable names only. Configuration is separated by `TIMEBITE_ENVIRONMENT`; non-production configurations reject Plaid Production, while production rejects HTTP and localhost CORS origins.

## Operations

- `GET /health` is a process liveness check. `GET /ready` verifies MongoDB connectivity.
- Startup creates required indexes and applies moderate JSON-schema validation. The Atlas role therefore needs index and collection-validation privileges during initialization; a stricter production pattern is to run initialization as a release job and remove those privileges from the runtime role.
- API errors have a stable `{error: {code, message, details, request_id}}` envelope. `X-Request-ID` is accepted and returned. Logs must contain only method, route, status, latency, and request ID—never request bodies or authorization headers.
- The in-process limiter protects a single instance. Production ingress must enforce a distributed per-IP and per-user rate limit (recommended: 60 auth attempts/15 minutes and 120 authenticated requests/minute) before horizontal scaling.
- CORS is disabled unless explicit origins are configured. Native iOS clients do not require CORS.
- MongoDB is the synchronized source of truth. Client mutations carry stable UUIDs and `base_updated_at`. Concurrent edits return a server-wins 409; the client keeps its draft for user review. Mutation IDs make retries idempotent.
- Account deletion is retry-safe and first calls Plaid `/item/remove`; if Plaid is unavailable, deletion returns an error rather than silently retaining a linked Item. A production job should retry an explicit deletion-request record before final erasure if asynchronous deletion is preferred.

## Remaining external boundary

Before accepting public traffic, put the API behind a managed edge rate limiter. Plaid webhooks are verified with the ES256 key returned by `/webhook_verification_key/get`, a five-minute replay window, and a constant-time SHA-256 comparison against the exact raw body. Keep `TIMEBITE_PLAID_WEBHOOK_VERIFICATION=true` outside isolated unit tests.

Apple server-to-server notifications also require external Apple Developer configuration. Configure the HTTPS endpoint after hosting exists; validate Apple's signed payload with Apple public keys, then map the Apple subject to the internal user. Do not accept a client-supplied user ID.
