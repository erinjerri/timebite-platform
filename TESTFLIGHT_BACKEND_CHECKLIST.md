# Private TestFlight beta setup

Do not paste any secret into chat, source, Xcode build settings committed to Git, or App Store review notes. Store backend secrets in the hosting provider's secret manager and developer-only values in an ignored local environment file.

## Values required from the owner

| Value | Obtain it from | Store it in | Verification |
| --- | --- | --- | --- |
| Development and production Atlas SRV URIs | MongoDB Atlas → Database Access and Connect | Separate hosting secret environments as `TIMEBITE_MONGO_URI` | `/ready` succeeds and the runtime user cannot access the other project |
| Production API HTTPS origin | Chosen hosting service/custom domain | Release-only `TIMEBITE_API_BASE_URL` and `TIMEBITE_PUBLIC_BASE_URL` | Release archive Info.plist contains HTTPS and no localhost |
| Apple client/bundle ID configuration | Apple Developer → Certificates, IDs & Profiles → `com.timebite.app` | `TIMEBITE_APPLE_CLIENT_ID`; enable capability on App ID | Real device Apple credential is accepted for the expected audience |
| Plaid Sandbox client ID and Sandbox secret | Plaid Dashboard → Developers → Keys | `TIMEBITE_PLAID_CLIENT_ID` and `TIMEBITE_PLAID_SECRET` in backend secrets | Link uses Sandbox institution credentials and exchange returns an Item |
| Plaid OAuth redirect URI | A chosen HTTPS app domain, then Plaid Dashboard → Developers → API | `TIMEBITE_PLAID_REDIRECT_URI`; Associated Domains entitlement | OAuth institution returns to the app through a Universal Link |
| JWT signing key | Generate in the secret manager or with `openssl rand -base64 48` | `TIMEBITE_JWT_SIGNING_KEY` | Old/incorrect signatures are rejected |
| 32-byte encryption key | Generate with `openssl rand -base64 32 | tr '+/' '-_'` | `TIMEBITE_TOKEN_ENCRYPTION_KEY` | Stored Plaid token ciphertext differs on repeated encryption and decrypts only with this key |

## Atlas

- Create separate development and production projects, networks, least-privilege users, and alerting.
- Run API startup once with index/schema privileges; verify indexes listed in `backend/app/database.py`, then consider a reduced runtime role.
- Enable continuous backups and point-in-time restore in production; document retention and perform a restore drill before external beta expansion.
- Verify every user-owned collection has `user_id`; unique Plaid IDs remain global while all application reads/writes remain user-scoped.

## Hosting

- Configure every name in `backend/.env.example`. Use `development`, `test`, and `production` environments separately.
- Keep Plaid set to `sandbox` for this beta. Configure TLS, managed edge rate limiting, log redaction, health checks, and at least two process instances after using a distributed rate limiter.
- Send Plaid webhooks to `https://<api>/v1/plaid/webhooks`. Verify ES256 signatures and raw-body hashes remain enabled.
- Configure Apple server-to-server notifications after the API domain exists. Add a signed-payload endpoint, register it in Apple Developer, and test credential-revoked and account-deleted events.

## Universal Links and Apple

- Add `applinks:<chosen-domain>` to `TimeBite.entitlements` after choosing the domain.
- Host `https://<chosen-domain>/.well-known/apple-app-site-association` with no redirect and content type `application/json`. Its app ID is `<TEAM_OR_APP_ID_PREFIX>.com.timebite.app` and its component path should include `/plaid/*`.
- Register the identical HTTPS redirect URI in Plaid. Test cold-launch, background, cancelled OAuth, and reinstall return paths.
- Confirm Sign in with Apple is enabled for the App ID and provisioning profiles; configure server notifications for the hosted endpoint.

## Privacy and TestFlight review

- Publish a privacy policy describing account identifiers, synchronized user content, encrypted Plaid connection tokens, account metadata, balances, and transactions; state retention/deletion policy and subprocessors.
- Declare Financial Info, User Content, Identifiers, and optional Contact Info as linked to the user for app functionality, not tracking. Reconfirm Health and Fitness behavior before submission.
- Review notes must explain Sign in with Apple and Plaid Sandbox. Provide Plaid's documented Sandbox institution and test credentials in App Store Connect review notes—not in source or this repository.
- Verify Delete Account removes the user, refresh-token families, sync records, goals/actions/sessions, finance records, and calls Plaid `/item/remove`.
- Verify Disconnect Bank calls `/item/remove` and removes the Item's local/server accounts and transactions according to policy.
- Verify reinstall + Sign in with Apple restores server data into an empty SwiftData cache.

## Release gate

- Run backend tests and both unsigned Debug/Release device builds.
- Scan the Release executable and expanded Info.plist for `localhost`, `127.0.0.1`, `StubFinanceAccountConnector`, Plaid secrets, MongoDB URIs, JWT keys, and access tokens.
- Complete Sandbox Link, added/modified/removed transaction reconciliation, duplicate webhook delivery, `ITEM_LOGIN_REQUIRED` update mode, offline retry, two-user isolation, delete, disconnect, and reinstall tests against dedicated non-production accounts.

