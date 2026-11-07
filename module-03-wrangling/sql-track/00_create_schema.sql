DROP VIEW  IF EXISTS elections;
DROP TABLE IF EXISTS fact_state_vote;
DROP TABLE IF EXISTS dim_state;
DROP TABLE IF EXISTS dim_election;

CREATE TABLE dim_state (
  state_id    SERIAL PRIMARY KEY,
  state_name  TEXT NOT NULL UNIQUE,
  is_south    BOOLEAN NOT NULL,
  region      TEXT,                 -- NULL FOR DC
  is_state    BOOLEAN NOT NULL      -- FALSE for DC
);

CREATE TABLE dim_election (
  election_year  INTEGER PRIMARY KEY CHECK (election_year % 4 = 0),
  decade         INTEGER NOT NULL
);

CREATE TABLE fact_state_vote (
  state_id       INTEGER NOT NULL REFERENCES dim_state(state_id),
  election_year  INTEGER NOT NULL REFERENCES dim_election(election_year),
  dem_vote       NUMERIC (5,2) NOT NULL CHECK (dem_vote BETWEEN 0 AND 100),
  PRIMARY KEY (state_id, election_year)
);

CREATE OR REPLACE VIEW elections AS
SELECT s.state_name     AS state,
       f.dem_vote,
       f.election_year  AS year,
       s.is_south       AS south,
       s.region,
       s.is_state
FROM fact_state_vote f
JOIN dim_state s USING (state_id);