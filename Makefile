# events-service — see README.md. Needs ~/my-society's stack running first.
#
#   make up                  build + start everything (after a pre-flight check)
#   make up ENV=test         same, against my-society's test stack (.env.test)

ENV        ?= prod
ENV_FILE   := $(if $(filter prod,$(ENV)),.env,.env.$(ENV))
COMPOSE    := docker compose --env-file $(ENV_FILE)

# my-society's compose project name (network, postgres, pgbouncer, volumes are prefixed with it)
SOCIETY_PROJECT := $(shell grep -m1 '^SOCIETY_PROJECT=' $(ENV_FILE) 2>/dev/null | cut -d= -f2)
APP_PUBLIC_URL  ?= $(shell grep -m1 '^APP_PUBLIC_URL=' $(ENV_FILE) 2>/dev/null | cut -d= -f2-)
PG_CONTAINER    := $(SOCIETY_PROJECT)_postgres
PG_USER         := $(shell grep -m1 '^POSTGRES_USER=' $(ENV_FILE) 2>/dev/null | cut -d= -f2)
PG_DB           := $(or $(shell grep -m1 '^POSTGRES_DB=' $(ENV_FILE) 2>/dev/null | cut -d= -f2),society_events)
PSQL            := docker exec -i $(PG_CONTAINER) psql -v ON_ERROR_STOP=1 -U $(PG_USER) -d $(PG_DB)

BACKEND  := event-service registration-service ticket-service payment-service
FRONTEND := mfe-events mfe-booking mfe-payment mfe-tickets mfe-event-admin

.PHONY: help preflight up down restart ps logs build urls db-init seed migrate migrate-status shell-db check-shared \
        $(addprefix restart-,$(BACKEND) $(FRONTEND)) $(addprefix logs-,$(BACKEND) $(FRONTEND))

help: ## List targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*## "}{printf "  %-24s %s\n", $$1, $$2}'

preflight: ## Check that my-society's network, pgbouncer and user-service are up
	@test -f $(ENV_FILE) || { echo "✗ $(ENV_FILE) missing — copy .env.example and fill it in"; exit 1; }
	@docker network inspect $(SOCIETY_PROJECT)_network >/dev/null 2>&1 \
	  || { echo "✗ network $(SOCIETY_PROJECT)_network not found — start ~/my-society first (make up there)"; exit 1; }
	@docker inspect -f '{{.State.Running}}' $(SOCIETY_PROJECT)_pgbouncer 2>/dev/null | grep -q true \
	  || { echo "✗ $(SOCIETY_PROJECT)_pgbouncer is not running — start ~/my-society first"; exit 1; }
	@docker exec $(PG_CONTAINER) psql -U $(PG_USER) -d $(PG_DB) -tAc "SELECT to_regclass('user_svc.users')" 2>/dev/null | grep -q users \
	  || { echo "✗ user_svc.users not found in $(PG_DB) — my-society's core schema must exist first"; exit 1; }
	@echo "✓ my-society platform ($(SOCIETY_PROJECT)) is up"

up: preflight ## Build + start all event services and MFEs
	$(COMPOSE) up -d --build

down: ## Stop this stack (my-society keeps running; data is in my-society's volumes)
	$(COMPOSE) down

restart: preflight ## Rebuild + restart everything
	$(COMPOSE) up -d --build --force-recreate

ps: ## Container status
	$(COMPOSE) ps

logs: ## Follow all logs
	$(COMPOSE) logs -f

build: ## Build images without starting
	$(COMPOSE) build

urls: ## List public Swagger UI and MFE URLs
	@base="$(APP_PUBLIC_URL)"; \
	if [ -z "$$base" ]; then \
	  echo "APP_PUBLIC_URL is not set in $(ENV_FILE); showing paths relative to the public host."; \
	  base="<APP_PUBLIC_URL>"; \
	else \
	  base=$${base%/}; \
	fi; \
	printf 'Swagger UI:\n  Event service:        %s/api/events/docs\n  Registration service: %s/api/registrations/docs\n  Ticket service:       %s/api/tickets/docs\n  Payment service:      %s/api/payments/docs\n\n' \
	  "$$base" "$$base" "$$base" "$$base"; \
	printf 'MFE remotes:\n  Events:               %s/mfe-events/\n  Booking:              %s/mfe-booking/\n  Payment:              %s/mfe-payment/\n  Tickets:              %s/mfe-tickets/\n  Event admin:          %s/mfe-event-admin/\n' \
	  "$$base" "$$base" "$$base" "$$base" "$$base"

$(addprefix restart-,$(BACKEND) $(FRONTEND)): restart-%: preflight ## Rebuild + restart one service (e.g. make restart-event-service)
	$(COMPOSE) up -d --build $*

$(addprefix logs-,$(BACKEND) $(FRONTEND)): logs-%: ## Follow one service's logs (e.g. make logs-payment-service)
	$(COMPOSE) logs -f $*

# ── Database ─────────────────────────────────────────────────────────────────
# Same Postgres as my-society (shared DB, separate schemas + roles). This repo
# owns event_svc / registration_svc / ticket_svc / payment_svc.

db-init: preflight ## Apply db/init/10_events_schema.sql (idempotent; for a fresh my-society DB)
	$(PSQL) < db/init/10_events_schema.sql
	@echo "✓ events schema applied. Rotate the four role passwords if this was a fresh install (see the file's role blocks)."

seed: preflight ## Load demo event data (db/init/11_events_seed.sql — TRUNCATEs event tables first!)
	$(PSQL) < db/init/11_events_seed.sql

migrate: preflight ## Apply not-yet-recorded db/migrations/E*.sql (tracked in events_schema_migrations)
	@$(PSQL) -q -c "CREATE TABLE IF NOT EXISTS events_schema_migrations (filename TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"
	@applied=$$($(PSQL) -tAc "SELECT filename FROM events_schema_migrations"); \
	for f in db/migrations/E*.sql; do \
	  [ -e "$$f" ] || { echo "No migrations."; break; }; \
	  base=$$(basename $$f); \
	  if printf '%s\n' "$$applied" | grep -qxF "$$base"; then echo "✓ $$base (already applied)"; continue; fi; \
	  echo "→ Applying $$base…"; \
	  $(PSQL) < $$f && $(PSQL) -q -c "INSERT INTO events_schema_migrations (filename) VALUES ('$$base')" \
	    || { echo "✗ $$base FAILED — stopping (nothing recorded for it)."; exit 1; }; \
	done

migrate-status: preflight ## Show applied vs pending db/migrations/E*.sql
	@$(PSQL) -q -c "CREATE TABLE IF NOT EXISTS events_schema_migrations (filename TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"
	@applied=$$($(PSQL) -tAc "SELECT filename FROM events_schema_migrations"); \
	for f in db/migrations/E*.sql; do \
	  [ -e "$$f" ] || { echo "No migrations."; break; }; \
	  base=$$(basename $$f); \
	  if printf '%s\n' "$$applied" | grep -qxF "$$base"; then echo "✓ $$base"; else echo "· $$base (pending)"; fi; \
	done

shell-db: ## psql into the shared database
	docker exec -it $(PG_CONTAINER) psql -U $(PG_USER) -d $(PG_DB)

# ── Vendored shared code ─────────────────────────────────────────────────────
MY_SOCIETY ?= $(HOME)/my-society

check-shared: ## Diff shared/ against ~/my-society/services/shared (drift check)
	@diff -rq --exclude=__pycache__ --exclude=SHARED_VERSION shared $(MY_SOCIETY)/services/shared \
	  && echo "✓ shared/ matches $(MY_SOCIETY)/services/shared" \
	  || { echo "✗ shared/ has drifted — sync the fix to both copies and bump shared/SHARED_VERSION"; exit 1; }
