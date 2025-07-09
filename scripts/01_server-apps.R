# Name: 01_server-apps.R
# Description: Extract app data from shinyapps.io


# 0 - Load packages and functions ----

library(rsconnect)
library(dplyr)
library(lubridate)
library(stringr)
library(here)
library(readr)

source(here("R", "server_apps.R"))
source(here("R", "progress.R"))
source(here("R", "app_visibility.R"))
source(here("R", "app_hours_used.R"))


# 1 - Get app data from server ----

apps <- server_apps("scotland", 
                    visibility = TRUE, 
                    hours_used = TRUE)

  
# 2 - Identify organisations ----

org_lookup <- read_csv(here("lookups", "organisation_lookup.csv"))

apps <-
  apps %>%
  mutate(org_acronym = tolower(word(name, 1, sep = regex("[_-]")))) %>%
  left_join(org_lookup, by = join_by(org_acronym)) %>%
  rename(org = org_description) %>%
  select(-org_acronym)


# 3 - Save data ----

write_rds(
  apps,
  here("outputs", paste0(Sys.Date(), "_server-data.rds")),
  compress = "gz"
)


### END OF SCRIPT ###