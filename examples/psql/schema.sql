CREATE TABLE IF NOT EXISTS benchmarks (
    name TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS branches (
    name TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS stores (
    name TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS instance_types (
    name TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS scenarios (
    name TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS configs (
    id SERIAL PRIMARY KEY,
    benchmark TEXT NOT NULL REFERENCES benchmarks(name),
    scenario TEXT NOT NULL REFERENCES scenarios(name),
    store TEXT NOT NULL REFERENCES stores(name),
    instance_type TEXT NOT NULL REFERENCES instance_types(name),
    cache BOOLEAN NOT NULL,
    UNIQUE(benchmark,
           scenario,
           store,
           cache,
           instance_type)
);

CREATE TABLE IF NOT EXISTS experiments (
    id TEXT PRIMARY KEY,
    ts TIMESTAMPTZ NOT NULL,
    branch TEXT NOT NULL REFERENCES branches(name),
    commit TEXT NOT NULL,
    commit_ts TIMESTAMPTZ NOT NULL,
    username TEXT NOT NULL,
    details_url TEXT NOT NULL,
    exclude_from_analysis BOOLEAN DEFAULT false NOT NULL,
    exclude_reason TEXT
);

CREATE TABLE IF NOT EXISTS results (
  experiment_id TEXT NOT NULL REFERENCES experiments(id),
  config_id INTEGER NOT NULL REFERENCES configs(id),

  samples BIGINT NOT NULL,
  process_cumulative_rate_mean BIGINT NOT NULL,
  process_cumulative_rate_stderr BIGINT NOT NULL,
  process_cumulative_rate_diff BIGINT NOT NULL,

  process_cumulative_rate_mean_rel_forward_change DOUBLE PRECISION,
  process_cumulative_rate_mean_rel_backward_change DOUBLE PRECISION,
  process_cumulative_rate_mean_p_value DECIMAL,

  process_cumulative_rate_stderr_rel_forward_change DOUBLE PRECISION,
  process_cumulative_rate_stderr_rel_backward_change DOUBLE PRECISION,
  process_cumulative_rate_stderr_p_value DECIMAL,

  process_cumulative_rate_diff_rel_forward_change DOUBLE PRECISION,
  process_cumulative_rate_diff_rel_backward_change DOUBLE PRECISION,
  process_cumulative_rate_diff_p_value DECIMAL,

  PRIMARY KEY (experiment_id, config_id)
);