# postgres-container
Posgres Container & Resources

![CI](https://github.com/melinko2003/postgres-container/actions/workflows/ci.yml/badge.svg)

## Overview

This repository provides a minimal `docker-compose.yml` setup to run a PostgreSQL container for development and CI. It also includes an example environment file `postgres.env.example`, and an `init-scripts/` folder where SQL files are applied during first database initialization.

## Continuous Integration

A GitHub Actions workflow is included at `.github/workflows/ci.yml`. The workflow will:

- Copy `postgres.env.example` to `./.postgres.env.example` so Docker Compose can load the environment variables used to initialize the container.
- Start services with `docker compose up -d`.
- Wait until Postgres reports ready using `pg_isready`.
- Install the `psql` client on the runner and test connecting to the database on `localhost:5432` using the credentials from `postgres.env.example`.
- Run a small set of SQL commands to verify basic DB operations.
- Tear down the compose stack and remove volumes after the job finishes.

If you need to customize which Compose service is treated as Postgres, set the `PG_SERVICE` environment variable in the workflow or job.

## Run the CI steps locally

You can reproduce the CI checks locally with these commands from the repository root:

```bash
cp postgres.env.example ./.postgres.env.example
docker compose up -d --build
# Wait for the DB to be ready (or run the readiness loop below)
for i in $(seq 1 60); do
	docker compose exec -T Postgres pg_isready -U "$(grep '^POSTGRES_USER=' postgres.env.example | cut -d= -f2-)" -d "$(grep '^POSTGRES_DB=' postgres.env.example | cut -d= -f2-)" >/dev/null 2>&1 && break || sleep 2
done

# From the host (install postgresql-client if needed):
export PGPASSWORD="$(grep '^POSTGRES_PASSWORD=' postgres.env.example | cut -d= -f2-)"
psql -h localhost -p 5432 -U "$(grep '^POSTGRES_USER=' postgres.env.example | cut -d= -f2-)" -d "$(grep '^POSTGRES_DB=' postgres.env.example | cut -d= -f2-)" -c '\\conninfo'

docker compose down -v
```

Notes:
- If your Compose service is named differently than `Postgres`, replace `Postgres` in the commands above with the actual service name or set the `PG_SERVICE` variable used by the workflow.
- The `init-scripts/` folder is mounted into `/docker-entrypoint-initdb.d` in the official Postgres image; SQL files there run only on first-time initialization for the data volume. The CI workflow removes volumes on teardown so init scripts run on each CI run.

## Files of interest

- `docker-compose.yml` — Compose configuration that defines the Postgres service and mounts.
- `postgres.env.example` — Example env file used to initialize the database.
- `init-scripts/` — SQL files that run on DB init. Example: `init-scripts/01-ci-test.sql`.
- `.github/workflows/ci.yml` — CI workflow that builds and validates the container and credentials.
