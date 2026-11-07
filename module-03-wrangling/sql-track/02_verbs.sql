-- select
SELECT "year" , dem_vote FROM elections;

-- filter
select * from elections where year = 2008;
select * from elections where year = 2008 and state = 'Colorado';

-- mutate: computed colums live in SELECT 
select state, year, dem_vote,
       100 - dem_vote                      as other_parties_vote,
       abs(dem_vote - (100 - dem_vote))    as abs_vote_difference
from elections;

-- arrange 
select state , year, dem_vote
from elections
order by year desc, dem_vote asc;

-- summarize
select AVG(dem_vote)        as mean_dem_vote,
	   AVG(100 - dem_vote)  as mean_other_parties
from elections;