-- CI init script: creates a small table for CI verification
CREATE TABLE IF NOT EXISTS ci_init_test (
  id serial PRIMARY KEY,
  created_at timestamptz DEFAULT now()
);
INSERT INTO ci_init_test DEFAULT VALUES;
