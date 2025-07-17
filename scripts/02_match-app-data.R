
# 0 - Load packages and functions ----

library(here)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(janitor)

source(here("R", "get_latest_output.R"))
source(here("R", "url_remove_dates.R"))


# 1 - Read server data and manual record data ----

manual <- 
  read_rds(here("outputs", "2024-07-16_manual-record.rds")) %>%
  mutate(url_no_date = url_remove_dates(url),
         id = row_number()) %>%
  group_by(url_no_date) %>%
  filter(date == max(date)) %>%
  ungroup() %>%
  rename(manual_record_date = date)

server <- 
  read_rds(get_latest_output("server-data")) %>%
  mutate(url_no_date = url_remove_dates(url))


# 2 - Match data on URL and URL with dates removed ----

apps <- 
  server %>%
  left_join(manual %>% select(id, url), 
            by = "url") %>%
  left_join(manual %>% select(id, url_no_date),
            by = "url_no_date",
            suffix = c("_url", "_url_no_date"))

# Check
apps %>%
  mutate(url_match = !is.na(id_url), 
         url_no_date_match = !is.na(id_url_no_date), 
         same_match = id_url == id_url_no_date) %>%
  count(url_match, url_no_date_match, same_match)


# 3 - Tidy data ----

# Add manual record data
apps <- 
  apps %>%
  mutate(id = ifelse(!is.na(id_url), id_url, id_url_no_date)) %>%
  select(-url_no_date, -matches("^id_.*")) %>%
  left_join(manual %>% select(-url_no_date), 
            by = "id",
            suffix = c("", "_manual")) %>%
  select(-id, -url_manual) %>%
  mutate(contact_known = !is.na(manual_record_date))
  
# Merge organisation data

org_lookup <- 
  read_csv(here("lookups", "organisation_lookup.csv")) %>%
  select(org_description, sg_agency) %>%
  distinct()

apps <-
  apps %>%
  mutate(org = case_when(
    is.na(org) ~ org_manual,
    is.na(org_manual) ~ org,
    org == org_manual ~ org,
    org != org_manual ~ "mismatch"
  )) %>%
  select(-org_manual) %>%
  left_join(org_lookup, by = join_by(org == org_description))
  

# 4 - Save matched data ----

write_rds(
  apps,
  here("outputs", paste0(Sys.Date(), "_app-data.rds")),
  compress = "gz"
)


### END OF SCRIPT ###
