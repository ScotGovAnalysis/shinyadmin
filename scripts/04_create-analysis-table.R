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
  mutate(status = if_else(
    status %in% c("running", "sleeping"),
    "active",
    status
  )) %>%
  mutate(url_no_date = url_remove_dates(url),
         .after = url) %>%
  left_join(contacts, by = join_by(url_no_date)) %>%
  select(-url_no_date)


# 2 - Complete organisation data ----

# Use app name prefix to derive organisation (where contact data not present)

analysis <-
  analysis %>%
  mutate(url_prefix = extract_org_prefix(name)) %>%
  left_join(orgs %>% select(org_acronym, org_name),
            by = join_by(url_prefix == org_acronym)) %>%
  mutate(org = case_when(
    is.na(org) & !is.na(org_name) ~ org_name,
    is.na(org) ~ "Unknown",
    .default = org)) %>%
  select(-org_name, -url_prefix)

# Add organisation groups (SG agencies, PHS, Other, Unknown)

analysis <-
  analysis %>%
  left_join(
    orgs %>% select(org_name, org_group) %>% distinct(),
    by = join_by(org == org_name)
  ) %>%
  mutate(org_group = replace_na(org_group, "Unknown")) %>%
  relocate(org_group, .after = org)


# 3 - Write to ADM ----

write_dataframe_to_db(
  config$adm_server,
  config$database,
  config$schema,
  table_name = "analysis",
  dataframe = analysis
)


### END OF SCRIPT ###
