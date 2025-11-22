-- Create the role if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = 'app'
  ) THEN
    CREATE USER app WITH PASSWORD 'password';
  END IF;
END
$$;

-- Conditionally create the database (needs psql for \gexec)
SELECT 'CREATE DATABASE app'
  WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = 'app'
  )
\gexec

-- Grant privileges on the database
GRANT ALL PRIVILEGES ON DATABASE app TO app;

-- Switch to the new database to assign schema rights (you’ll need this in the script context)
\c pulp

-- Grant on the schema (public) so app can create tables, etc
GRANT USAGE, CREATE ON SCHEMA public TO app;

-- (Optional) For future tables created by other users, allow app to have rights:
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO app;