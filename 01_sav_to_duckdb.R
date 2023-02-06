# Reading .sav files and writing to duckdb
# created 20220203 by @vankesteren
library(tidyverse)
library(haven)
library(duckdb)
library(DBI)

# create a database file connection
con <- dbConnect(duckdb(), dbdir = "cbs.duckdb", read_only = FALSE)

# reading sav files to R tibble using haven::read_sav()
# These could have additional processing steps such as 
# converting labelled_factors to standard R factors
# (categorical variables)
# and processing time variables into actual timestamps
gba <- read_sav("sav_files/GBAPERSOON2018TABV2.sav")
opl <- read_sav("sav_files/HOOGSTEOPL2018TABV3.sav")
inp <- read_sav("sav_files/INPA2018TABV2.sav")


# efficiently copying memory to database using data base interface
dbWriteTable(con, "GBAPERSOON2018TABV2", gba)
dbWriteTable(con, "HOOGSTEOPL2018TABV3", opl)
dbWriteTable(con, "INPA2018TABV2", inp)

# disconnect from the database
dbDisconnect(con)
  