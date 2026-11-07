# r-stuff

My hands-on work for **EAS345: Introduction to Data Science**. Every module is worked through in R,
then repeated as a **SQL track**: the same data modelled in PostgreSQL, queried in SQL, and read
from both R and Python. Each SQL track ends with a small reporting layer of views that Power BI
can connect to.

This repository is for learning. The code follows the course modules step by step, and each step
is a commit.

## Modules

| Module | Topic | Data | SQL track highlights |
| --- | --- | --- | --- |
| 3 | Data wrangling with dplyr | US presidential elections (`pscl`) | Star schema, dplyr verbs in SQL, CTEs, window functions, reporting views |
| 4 | Loading and exploring data | Car evaluation, German credit, PUMS codebook | Lookup tables for coded data, decoding with joins, crosstabs, credit-risk views |
| 5 | Exploratory data analysis and visualization | Customer data (`custdata`) | Data profiling, binning for histograms, aggregating in SQL and plotting in R/Python |
| 6 | Data cleaning and dplyr | `custdata`, `nycflights13` | NULL rules, imputation, foreign keys as data checks, a date dimension, on-time KPIs |
| 7 | Statistics: distributions and confidence intervals | Normal samples, slide examples, flights | Wide-to-long reshaping, z-scores, IQR outliers, the CLT on real data, a t-value lookup table |
| 8 | Hypothesis testing and linear regression | Oxygen purity, Anscombe, wind tunnel | `REGR_` aggregates, z-test p-values with `erfc()`, one regression per group |
| 9 | Regression diagnostics | `mtcars`, `cars` | Storing models as data, scoring in SQL, leverage and Cook's distance, model monitoring |
| 10 | Logistic regression and classifiers | Natality risk data, iris | Logistic scoring in SQL, confusion matrix, AUC, threshold and decile views |
| 11 | Clustering | NFL player stats | Full outer joins, feature engineering, similarity search, k-means assignment in SQL |

Each module folder has its own `README.md` with the results and notes for that module.

## Repository layout

```
r-stuff/
  README.md
  .gitignore
  module-03-wrangling/
    ...                 R work for the module
    sql-track/          SQL, R and Python for the SQL track
      README.md
  module-04-.../
  ...
  module-11-.../
```

SQL track scripts are numbered in the order they run (`00_create_schema.sql`, `01_load_data.R`,
`02_...`), so each folder can be rebuilt from scratch by running them in sequence.

## Tools

- **R:** tidyverse (dplyr, ggplot2), DBI, RPostgres, dbplyr, plus module packages (rpart, class,
  pROC, lmtest, car, nycflights13, pscl)
- **Python:** pandas, SQLAlchemy, psycopg, scipy, statsmodels, scikit-learn, matplotlib
- **Database:** PostgreSQL 16 (database `eas345`), with DuckDB as a no-install fallback
- **Reporting:** Power BI, connected to the SQL views

## Setup (Ubuntu)

```bash
# PostgreSQL 16
sudo apt install postgresql postgresql-contrib
sudo -u postgres psql
#   CREATE ROLE student LOGIN PASSWORD '...' CREATEDB;
#   CREATE DATABASE eas345 OWNER student;

# System libraries for R packages that compile on Linux
sudo apt install build-essential libpq-dev libssl-dev libcurl4-openssl-dev libxml2-dev

# Python, inside a virtual environment
sudo apt install python3-venv python3-full
python3 -m venv .venv
source .venv/bin/activate
pip install pandas sqlalchemy "psycopg[binary]" duckdb python-dotenv scipy statsmodels scikit-learn matplotlib jupyter
```

### Connection details

Database credentials are read from environment files that are **never committed**:

- `.Renviron` for R: `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`
- `.env` for Python: the same variables, loaded with `python-dotenv`

```
# .gitignore
.Renviron
.env
.venv/
*.duckdb
.Rhistory
.RData
```

Run `git status` before every commit to check that neither file is listed.

## Ideas that run through the SQL tracks

- **Let the database do the counting.** Aggregate in SQL, then plot or model the small result
  in R or Python.
- **Constraints check the data.** Primary keys, foreign keys and `CHECK` constraints catch
  duplicates, orphans and impossible values when the data is loaded.
- **Business rules live in views.** Definitions such as "close race", "late flight" or "at-risk"
  are written once, in SQL, and every tool reads the same answer.
- **Models are data.** Coefficients, scaling parameters and centroids are stored in tables, so
  SQL can score new rows without R or Python running.
- **Check against a second tool.** SQL results are compared with R (`lm()`, `t.test()`,
  `kmeans()`, ...) and Python before they are trusted.

## Commit convention

```
modNN: <what changed>          R work for module NN
modNN-sql: <what changed>      SQL track for module NN
```

For example: `mod03-sql: star schema for elections and R loader`.