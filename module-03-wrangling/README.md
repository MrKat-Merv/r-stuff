# EAS345 Module 3: SQL Track (Postgres with R and Python)

Companion to the Module 3 data-wrangling work. The same US presidential election data
(`pscl::presidentialElections`) is modelled as a star schema in PostgreSQL, queried in SQL,
read from R (DBI, dbplyr) and Python (pandas, SQLAlchemy), and published as a small
reporting layer of views that Power BI can read directly.

The goal is to be able to answer every Module 3 dplyr question three ways, in SQL, R and
Python, and to get the same answer each time.

## Data model

A star schema: one fact table of measurements, surrounded by dimension tables that describe them.

```
   dim_state                    fact_state_vote                 dim_election
 +-----------------+         +----------------------+         +------------------+
 | state_id   (PK) |1 ----- *| state_id       (FK)  |* ----- 1| election_year(PK)|
 | state_name      |         | election_year  (FK)  |         | decade           |
 | is_south        |         | dem_vote             |         +------------------+
 | region          |         +----------------------+
 | is_state        |          PK (state_id, election_year)
 +-----------------+
```

| Table | Rows | Notes |
| --- | --- | --- |
| `dim_state` | 51 | 50 states + DC. DC has `is_state = FALSE` and a NULL `region` |
| `dim_election` | 22 | 1932 to 2016; `CHECK (election_year % 4 = 0)` |
| `fact_state_vote` | 1,097 | Democratic vote share; `CHECK (dem_vote BETWEEN 0 AND 100)` |

Constraints do the data checking: the primary keys stop duplicate state-years, the foreign keys
stop votes for states or years that don't exist, and the `CHECK`s stop impossible values.

## Setup (Ubuntu)

```bash
# PostgreSQL
sudo apt install postgresql postgresql-contrib
sudo -u postgres psql          # then: CREATE ROLE student LOGIN PASSWORD '...' CREATEDB;
                               #       CREATE DATABASE eas345 OWNER student;
psql -h localhost -U student -d eas345    # test the login

# R (RPostgres compiles from source on Linux)
sudo apt install build-essential libpq-dev libssl-dev libcurl4-openssl-dev libxml2-dev
Rscript -e 'install.packages(c("DBI", "RPostgres", "dbplyr", "dplyr", "pscl", "duckdb"))'

# Python: always inside the virtual environment
sudo apt install python3-venv python3-full
python3 -m venv .venv
source .venv/bin/activate
pip install pandas sqlalchemy "psycopg[binary]" duckdb python-dotenv jupyter
```

Connection details live in files that are **never committed** (both are in `.gitignore`):

- `.Renviron` (R): `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`
- `.env` (Python): the same five variables, read with `python-dotenv`

## How to run

From `sql-track/`, in this order:

| Step | File | What it does |
| --- | --- | --- |
| 1 | `00_create_schema.sql` | Drops and recreates the three tables with keys and checks |
| 2 | `01_load_data.R` | Builds the dimensions, then the fact table, and loads them with `dbAppendTable` |
| 3 | `02_verbs.sql`, `02_verbs.py` | dplyr verbs (`filter`, `select`, `mutate`, `arrange`, `summarize`) in SQL and pandas |
| 4 | `03_question_three_ways.sql` | "Highest Democratic vote in 2008" as a subquery, a CTE and a window function |
| 5 | `04_going_further.sql` | `GROUP BY`/`FILTER`, `HAVING`, `CASE`, the South query, gap-audit joins, window functions |
| 6 | `05_pipeline.R`, `05_pipeline.py` | The full pipeline from R (DBI and dbplyr) and from Python (pandas and SQLAlchemy) |
| 7 | `06_reporting_views.sql` | Creates the three reporting views below |
| 8 | `06_check_views.R`, `06_check_views.py` | Reads the views from both languages |
| 9 | `07_drills.sql` | Ten SQL drills with checked answers |

```bash
psql -h localhost -U student -d eas345 -f 00_create_schema.sql
Rscript 01_load_data.R
psql -h localhost -U student -d eas345 -f 06_reporting_views.sql
```

## Reporting layer

Three views carry the business rules, so every tool (R, Python, Power BI) uses the same definitions.

| View | Grain | Columns |
| --- | --- | --- |
| `vw_state_results` | one row per state per election | `state_name`, `region`, `is_south`, `is_state`, `election_year`, `dem_vote`; `other_vote` = 100 − `dem_vote`; `margin` = \|2 × `dem_vote` − 100\|; `dem_majority` = `dem_vote` > 50; `change_from_last` = change since the previous election (`LAG`) |
| `vw_election_summary` | one row per election | `places_reporting`, `mean_dem_vote`, `places_dem_majority`, `close_races` (margin < 10) |
| `vw_battlegrounds` | one row per state | states (not DC) with at least 5 close races since 1992: `close_races_since_1992`, `lowest_dem`, `highest_dem` |

The summary and battleground views read from `vw_state_results`, so `margin` is defined in one
place only. The views hold no `ORDER BY`; each query or visual sorts the way it needs.

**Power BI:** Get Data > PostgreSQL database > server `localhost`, database `eas345` > import the
three tables and three views. In Model view, check `dim_state` 1-to-many `fact_state_vote` on
`state_id` and `dim_election` 1-to-many `fact_state_vote` on `election_year`.

## Results

**Recent elections** (`vw_election_summary`):

| Year | Places | Mean Dem vote | Dem majorities | Close races |
| --- | --- | --- | --- | --- |
| 2016 | 50 | 45.07 | 14 | 19 |
| 2012 | 51 | 48.99 | 26 | 15 |
| 2008 | 51 | 51.29 | 27 | 13 |

**Battleground states since 1992** (`vw_battlegrounds`), 11 states:

- **7 close races:** Pennsylvania (Democratic vote 45.15 to 54.47)
- **6:** Florida (39.00 to 50.91), Minnesota, New Hampshire, New Mexico
- **5:** Iowa, Michigan, Ohio, Oregon, Virginia, Wisconsin

**Other findings**

- **DC distorts "highest vote" questions.** DC's 92.46 in 2008 beats every state (Hawaii is next
  at 71.85). Filtering on `is_state` in `dim_state` fixes this in one place.
- **Ratings for 2016:** Lean D 6, Lean R 13, Safe D 8, Safe R 23 (from a `CASE` on the margin).
- **The most-Democratic states:** Massachusetts had a Democratic majority in 17 of the 22
  elections and Rhode Island in 16 (`HAVING`).
- **Top state by year:** Rhode Island 2000, Massachusetts 2004, Hawaii 2008 to 2016 (window function).

## Data notes and caveats

- **Missing rows are real history, mostly.** A `CROSS JOIN` of states and elections, `LEFT JOIN`ed
  to the facts, finds three gaps: Alabama 1948 and Alabama 1964 (Truman and then Johnson were not
  on Alabama's ballot) and Wyoming 2016 (missing from the dataset). Alaska and Hawaii start in
  1960 and DC in 1964, which is also history.
- **`margin` is not the Democrat-vs-Republican margin.** It compares the Democrat with
  *everyone else*, so in years with strong third-party candidates (1992, 2016) it differs from
  the two-party margin. Read "close race" with that in mind.
- **"No Democratic majority" is not "Democrat lost."** In 2016 the Democrat won several states
  (Colorado, Maine, Minnesota, Nevada, New Hampshire, New Mexico, Virginia) with under 50% of
  the vote. `dem_majority` measures the majority, not the winner.

## What I practised

- Designing a star schema with keys and checks, and loading it from R
- Translating dplyr verbs into SQL, and the logical order in which SQL runs a query
- Subqueries, CTEs, window functions (`LAG`, `RANK`, `ROW_NUMBER`, moving averages)
- Conditional aggregation (`COUNT(*) FILTER`, `SUM(CASE ...)`), `HAVING`, gap audits with joins
- Parameterized queries (no SQL injection) from both R and Python
- A reporting layer of views for Power BI

## Commits

```
mod03-sql: set up postgres track and ignore secrets
mod03-sql: star schema for elections and R loader
mod03-sql: dplyr verbs in SQL, R and pandas
mod03-sql: subqueries, CTEs, joins and window functions
mod03-sql: R and Python pipelines against postgres
mod03-sql: reporting views for BI
mod03-sql: SQL drills
```