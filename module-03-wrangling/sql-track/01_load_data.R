library(DBI); library(dplyr); library(pscl)
con <- dbConnect(RPostgres::Postgres())   # credentials come from .Renviron

dbGetQuery(con, "SELECT current_database()")   # should say eas345

pe <- presidentialElections
regions <- data.frame(state_name = state.name, region = as.character(state.region))

dim_state <- pe %>%
  distinct(state_name = state, is_south = south) %>%
  left_join(regions, by = "state_name") %>%
  mutate(is_state = state_name != "DC") %>%
  arrange(state_name)

dim_election <- pe %>%
  distinct(election_year = year) %>%
  mutate(decade = election_year %/% 10 * 10)   # %/% is integer division: 1936 -> 1930

dbAppendTable(con, "dim_state", dim_state)
dbAppendTable(con, "dim_election", dim_election)

# look up the IDs Postgres assigned, then build the fact table with them
ids <- dbGetQuery(con, "SELECT state_id, state_name FROM dim_state")
fact <- pe %>%
  inner_join(ids, by = c("state" = "state_name")) %>%
  transmute(state_id, election_year = year, dem_vote = demVote)
dbAppendTable(con, "fact_state_vote", fact)

dbGetQuery(con, "SELECT COUNT(*) FROM fact_state_vote")   # 1097
dbDisconnect(con)

