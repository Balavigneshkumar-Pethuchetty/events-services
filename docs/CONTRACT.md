# Contract between events-service and my-society

This file lists everything one repo relies on from the other. A breaking change to anything here is a coordinated release:

1. Change the provider in a backwards-compatible way and deploy it.
2. Update and deploy the consumer.
3. Then remove the old behaviour.

Keep this file and `~/my-society/ARCHITECTURE.md` in sync.

## my-society provides → events-service consumes

### user-service internal API (`http://user-service:3001/internal/users`, header `X-Internal-Key`)

| Method & path | Used by | Purpose |
|---|---|---|
| `GET /by-sub/{keycloak_sub}` | all four | Resolve the caller to an internal user |
| `GET /{user_id}` | all four | One user |
| `GET /by-ids?ids=a,b` | all four | Batch user lookup |
| `GET /by-email/{email}` | event | Organizer / permission-grantee lookup |
| `GET /by-role/{role}` | payment | Admin/committee recipients |
| `GET /broadcast-targets` | event | Announcement recipients |
| `POST /{user_id}/notifications` | event, registration, payment | Write an in-app bell notification |
| `POST /notifications/clear` | payment | Delete resolved action-item notifications (`{types, related_ids}`) |
| `POST /guest` | registration | Placeholder `users` row for a complimentary-ticket guest |

The client is `shared/user_client.py`.

### Infrastructure (on network `${SOCIETY_PROJECT}_network`)

`pgbouncer:6432`, `redis:6379`, `minio:9000`, `novu-api:3000`, `notification-service:3009`, the Splunk HEC on the host (`host.containers.internal:8088`), and Keycloak's JWKS (`KEYCLOAK_URL`, realm `society-events`).

### Database (shared `society_events`)

- events-service tables have FKs into `user_svc.users`, `society` and `core.currency`/`core.exchange_rate`. So my-society's core schema (`db/init/01_schema.sql`) must exist before `db/init/10_events_schema.sql` runs.
- `core.notification.event_id` has an FK into `event_svc.event` (`notification_event_id_fkey`, `ON DELETE SET NULL`). It is created by `10_events_schema.sql`.
- Roles `event_role`, `registration_role`, `ticket_role` and `payment_role` have **no** grants on `user_svc.*` or `core.notification` (migration 044).

### Shared secrets and config

`INTERNAL_API_KEY`, `KEYCLOAK_URL`/`KEYCLOAK_PUBLIC_URL`, `APP_PUBLIC_URL`, the four `*_DB_USER`/`*_DB_PASSWORD` pairs, `REDIS_PASSWORD`, MinIO credentials, and `SOCIETY_ID` (`11100000-0000-0000-0000-000000000001`).

## events-service provides → my-society consumes

### Internal APIs used by user-service (`X-Internal-Key`)

| Service | Method & path | Purpose |
|---|---|---|
| event-service | `GET /internal/events/{id}`, `GET /internal/events?ids=` | Event titles for leave-request blockers and the activity export |
| event-service | `GET /internal/events/authorship-summary/{user_id}` | Organizer, announcement and permission blockers |
| ticket-service | `GET /internal/tickets/by-user/{user_id}` | Ticket history for the activity export |
| registration-service | `GET /internal/registrations/members/{user_id}/activity` | Registration history for the activity export |
| registration-service | `POST /internal/registrations/members/{user_id}/erase` | Delete a leaving member's registrations. Idempotent. Returns `{deleted_ids}`. |
| payment-service | `GET /internal/payments/members/{user_id}/blockers` | `{pending_payment_event_ids, collector_event_ids, open_sponsorship_refund_count}` |
| payment-service | `GET /internal/payments/members/{user_id}/activity` | Payment history for the activity export |
| payment-service | `POST /internal/payments/members/{user_id}/erase` | Delete a leaving member's payment transactions. Idempotent. Returns `{deleted_ids}`. |

user-service must degrade gracefully if these are down. Leave-request pages then show "Event data is temporarily unavailable", and the final confirm stays blocked.

### DNS names (compose service names; nginx proxies to them)

`event-service:3002`, `registration-service:3005`, `ticket-service:3006`, `payment-service:3007`, `mfe-events:80`, `mfe-booking:80`, `mfe-payment:80`, `mfe-tickets:80`, `mfe-event-admin:80`.

### Module-federation remotes (loaded by my-society's shell)

| Remote | Exposed module | Props | Shell route |
|---|---|---|---|
| `mfe_events` | `./EventsApp` | `token` | `/events/*` |
| `mfe_booking` | `./BookingApp` | `token` | `/registrations/*` |
| `mfe_payment` | `./PaymentApp` | `token` | `/checkout/*`, `/payments/*` |
| `mfe_tickets` | `./TicketsApp` | `token` | `/tickets/*` |
| `mfe_tickets` | `./GateScanner` | `token` | `/scanner` |
| `mfe_tickets` | `./EntryLog` | `token` | `/entry-log` |
| `mfe_event_admin` | `./ManageRoutes` | `token, page, id` | `/manage/*` |
| `mfe_event_admin` | `./EventAdminRoutes` | `token, page, role` | `/admin/{payments,reconciliation,pay-refunds,sponsors,categories,refunds}`, and `/admin` for committee members |
| `mfe_event_admin` | `./SponsorApp` | `firstName, token` | `/sponsor` |

The `/admin` page list is duplicated in the shell (`EVENT_ADMIN_PAGES` in `frontend/shell/src/App.tsx`) and in `frontend/mfe-event-admin/src/EventAdminRoutes.tsx`. Change both together.

Shared singletons, which must match the shell's ranges: react `^18.3.1`, react-dom `^18.3.1`, react-router-dom `^6.24.1`, @mui/material `^5.16.7`, @emotion/react and @emotion/styled `^11.13.0`, i18next `^26.3.6`, react-i18next `^17.0.11`.
