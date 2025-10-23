# Name: xx_create-analysis-table.R
# Description: Match contact data to server data to create table for analysis


# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Join server apps and contacts ----

contacts <-
  read_table_from_db(
    config$adm_server,
    config$database,
    config$schema,
    "contacts_all"
  )

analysis <- 
  read_table_from_db(
    config$adm_server,
    config$database,
    config$schema,
    "server_apps" 
  ) %>%
  mutate(url_no_date = url_remove_dates(url),
         .after = url) %>%
  left_join(contacts, by = join_by(url_no_date))


# 2 - Complete organisation data ----

# Use app name prefix to derive organisation
analysis <-
  analysis %>%
  mutate(url_prefix = extract_org_prefix(name)) %>%
  left_join(lookups$orgs %>% select(org_acronym, org_description), 
            by = join_by(url_prefix == org_acronym)) %>%
  mutate(org = if_else(is.na(org), org_description, org)) %>%
  select(-org_description, -url_prefix)
  
# Match on sg_agency flag from org lookup

agency_lookup <- 
  lookups %>% 
  pluck("orgs") %>%
  select(org_description, sg_agency) %>% 
  distinct()

analysis <-
  analysis %>%
  left_join(agency_lookup, by = join_by(org == org_description)) %>%
  relocate(sg_agency, .after = org_other)


# 3 - Write to ADM ----

write_dataframe_to_db(
  config$adm_server,
  config$database,
  config$schema,
  table_name = "analysis",
  dataframe = analysis
)


### END OF SCRIPT ###
