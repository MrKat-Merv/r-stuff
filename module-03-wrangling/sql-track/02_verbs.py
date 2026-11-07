# import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()                     # reads .env into os.environ
from sqlalchemy import create_engine, URL
import os

url = URL.create(
    "postgresql+psycopg",
    username=os.getenv("PGUSER"),
    password=os.getenv("PGPASSWORD"),
    host=os.getenv("PGHOST", "localhost"),
    port=int(os.getenv("PGPORT", 5432)),
    database=os.getenv("PGDATABASE"),
)
engine = create_engine(url)

el = pd.read_sql("SELECT * FROM elections", engine)
el.shape                                                  # (1097, 6)

el[["year", "dem_vote"]]                                  # select
el[el.year == 2008]                                       # filter
el[(el.year == 2008) & (el.state == "Colorado")]          # two conditions: & with brackets
el = el.assign(other_parties_vote = 100 - el.dem_vote)    # mutate
el["abs_vote_difference"] = (el.dem_vote - el.other_parties_vote).abs()
el.sort_values(["year", "dem_vote"], ascending=[False, True]).head(3)   # arrange
el[["dem_vote", "other_parties_vote"]].mean()            # summarize: 48.36, 51.64
