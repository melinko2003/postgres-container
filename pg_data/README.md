Postgres Data Goes here

This directory is mounted into the Postgres container as the data volume (see `docker-compose.yml`). Notes:

- The Postgres image initializes the database only on first startup for a new empty volume. Files in the repository's `init-scripts/` directory are executed on initial database creation.
- If you need CI to run init scripts on every run, ensure the Compose workflow or local commands remove the volume between runs (e.g. `docker compose down -v`).
- To inspect or back up the data directory locally, stop containers first and then access the `pg_data/` folder.

Local reproduction (from repo root):

```bash
cp postgres.env.example ./.postgres.env.example
docker compose up -d --build
# Wait for readiness
for i in $(seq 1 60); do
	docker compose exec -T Postgres pg_isready -U "$(grep '^POSTGRES_USER=' postgres.env.example | cut -d= -f2-)" -d "$(grep '^POSTGRES_DB=' postgres.env.example | cut -d= -f2-)" >/dev/null 2>&1 && break || sleep 2
done

# When finished:
docker compose down -v
```