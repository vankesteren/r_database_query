# Reading .sav files and writing to duckdb
# created 20220203 by @vankesteren
library(tidyverse)
library(dbplyr)
library(duckdb)
library(DBI)

# create a database file connection, read only
con <- dbConnect(duckdb(), dbdir = "cbs.duckdb", read_only = TRUE)


# query and join tables using dbplyr
# first, create lazy table objects (they don't load in memory!)
gba <- tbl(con, "GBAPERSOON2018TABV2") 
opl <- tbl(con, "HOOGSTEOPL2018TABV3") 
inp <- tbl(con, "INPA2018TABV2") 
  
# create a cohort table with opleiding & income using standard 
# tidyverse keywords
my_tab <- 
  gba |> 
  filter(GBAGEBOORTEJAAR > 2000) |> 
  select(RINPERSOON, RINPERSOONS, GBAGESLACHT) |> 
  left_join(opl, by = c("RINPERSOON", "RINPERSOONS")) |> 
  left_join(inp, by = c("RINPERSOON", "RINPERSOONS")) |> 
  collect()

# this is all processing in duckdb, see the SQL query here: 
gba |> 
  filter(GBAGEBOORTEJAAR > 2000) |> 
  select(RINPERSOON, RINPERSOONS, GBAGESLACHT) |> 
  left_join(opl, by = c("RINPERSOON", "RINPERSOONS")) |> 
  left_join(inp, by = c("RINPERSOON", "RINPERSOONS")) |> 
  show_query()

# now do some R variable type preprocessing
my_tab_proc <- 
  my_tab |> 
  mutate(
    RINPERSOON = as.integer(RINPERSOON),
    RINPERSOONS = factor(RINPERSOONS),
    geslacht = factor(ifelse(GBAGESLACHT == 1, "m", "f")),
    edu_level = factor(OPLNIVSOI2016AGG4HBMETNIRWO, ordered = TRUE),
    log_income = log1p(INPPERSBRUT)
  ) |> 
  select(geslacht, edu_level, log_income)

# then, do some complicated modeling thing
summary(lm(log_income ~ edu_level + geslacht, data = my_tab_proc))
