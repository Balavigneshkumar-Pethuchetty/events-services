# events-service

Everything event-related for the society platform, split out of `~/my-society`. The plan and rationale are in `~/my-society/EVENTS_SERVICE_PLAN.md`:

| Kind | Name | Port | Public path (via my-society's nginx) |
|---|---|---|---|
| Backend | event-service | 3002 | `/api/events/` |
| Backend | registration-service | 3005 | `/api/registrations/` (incl. `/complimentary/*`) |
| Backend | ticket-service | 3006 | `/api/tickets/` |
| Backend | payment-service | 3007 | `/api/payments/` |
| Frontend | mfe-events | 4001 | `/mfe-events/` → shell `/events` |
| Frontend | mfe-booking | 4002 | `/mfe-booking/` → shell `/registrations` |
| Frontend | mfe-payment | 4003 | `/mfe-payment/` → shell `/checkout`, `/payments` |
| Frontend | mfe-tickets | 4005 | `/mfe-tickets/` → shell `/tickets`, `/scanner`, `/entry-log` |
| Frontend | mfe-event-admin | 4007 | `/mfe-event-admin/` → shell `/manage/*`, event pages of `/admin/*`, `/sponsor` |

## It is not a standalone stack

This repo runs **on top of** `~/my-society`, the same way `~/communication-service` does. It uses that repo's:

- **Postgres** (`society_events`, through pgbouncer). This repo owns the `event_svc`, `registration_svc`, `ticket_svc` and `payment_svc` schemas and connects as `event_role`, `registration_role`, `ticket_role` and `payment_role`.
- **redis** and **minio**.
- **nginx**, the only public entry point and the Cloudflare tunnel's target.
- **user-service**, for every user lookup and in-app notification, over `/internal/users/*`.
- **Keycloak**, through the same realm, roles and JWKS.

The containers join my-society's Docker network. Their compose **service names are the DNS names** that nginx and user-service call, so don't rename them. Everything that crosses the boundary is listed in [docs/CONTRACT.md](docs/CONTRACT.md).

## Run

```bash
cd ~/my-society && make up        # platform first
cd ~/events-service && make up    # pre-flight check, then build + start
make ps / make logs / make logs-payment-service
make restart-event-service        # rebuild + redeploy one service
make up ENV=test                  # against my-society's test stack (.env.test)
```

`.env` / `.env.test` (gitignored) hold the same DB role passwords, `INTERNAL_API_KEY` and Keycloak URLs as my-society. `.env.example` lists every key.

Frontend dev: `cd frontend/<mfe> && npm run dev`. my-society's shell dev server (`make frontend` there) loads the remotes from `localhost:4001–4007`.

## Database

```bash
make db-init        # apply db/init/10_events_schema.sql (idempotent) — fresh installs, after my-society's core schema
make seed           # demo data (db/init/11_events_seed.sql) — TRUNCATEs event tables first
make migrate        # apply new db/migrations/E0NN_*.sql, tracked in events_schema_migrations
make migrate-status
```

When you change the schema, write a new `db/migrations/E0NN_name.sql`, which must be idempotent. Make the same change in `db/init/10_events_schema.sql`, then run `make migrate`. Migrations 001–044 in my-society are history and still live there.

## Shared code

`shared/` is a **vendored copy** of `~/my-society/services/shared`: auth, DB pool, user-service client, MinIO and redis helpers. If you fix a bug there, apply it to both copies and bump `shared/SHARED_VERSION`. `make check-shared` reports drift.

## Rules of the boundary

- No SQL against `user_svc.*`. Use `shared/user_client.py`, which calls user-service's internal API.
- No writes to `core.notification`. Use `post_notification` / `clear_notifications`.
- `/internal/*` routers require `X-Internal-Key`. nginx returns 404 for them publicly.
- Shared federation singletons (react 18.3, react-dom, react-router-dom 6.24, @mui/material 5.16, @emotion/*, i18next 26, react-i18next 17) must stay version-compatible with my-society's shell.
