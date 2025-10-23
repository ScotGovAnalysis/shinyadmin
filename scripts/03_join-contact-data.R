# Name: 03_join-contact-data.R
# Description: Clean contact data and join old contact data


# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Clean contact data ----

contacts_new <- 
  read_table_from_db(
    config$adm_server,
    config$database,
    config$schema,
    "contacts_new" 
  ) %>%
  mutate(url = clean_manual_url(url))


# Consolidate 'accepted' organisations into 1 column (`org`)

accept_orgs <- lookups$orgs %>% filter(ms_form_accepted)

contacts_new <- 
  contacts_new %>%
  mutate(
    other_org_valid = 
      str_remove(org_other, "\\s\\(.*\\)$") %in% accept_orgs$org_description,
    org = case_when(
      other_org_valid ~ org_other,
      .default = org
    ),
    org_other = if_else(other_org_valid, NA_character_, org_other),
    org = str_remove(org, "\\s\\(.*\\)$")
  ) %>%
  select(-other_org_valid, -response_id)
  

# Flag other orgs for manual review

orgs_to_review <-
  contacts_new %>%
  filter(!is.na(org_other)) %>%
  arrange(org_other) %>%
  relocate(org_other, url, .before = 0)

if (nrow(orgs_to_review) > 0) {
  cli::cli_inform(c(
    "!" = paste("{n_distinct(orgs_to_review$org_other)} organisation{?s}",
                "{?is/are} not in the expected list."),
    "i" = "View the {.code orgs_to_review} data frame to review.",
    "i" = paste("If the organisation should be accepted, add it to",
                "{.file lookups/organisation_lookup.csv}.")
  ))
}
 

# 2 - Join to old contact data ----

contacts_old <- 
  read_table_from_db(
    config$adm_server,
    config$database,
    config$schema,
    "contacts_old" 
  )

contacts_all <-
  bind_rows(
    contacts_new %>% mutate(contact_form = "new"),
    contacts_old %>% mutate(contact_form = "old")
  ) %>%
  mutate(url_no_date = url_remove_dates(url),
         .after = url) %>%
  group_by(url_no_date) %>%
  filter(form_completed_time == max(form_completed_time)) %>%
  ungroup() %>%
  select(-url)


# 3 - Write to ADM ----

write_dataframe_to_db(
  config$adm_server,
  config$database,
  config$schema,
  table_name = "contacts_all",
  dataframe = contacts_all
)


### END OF SCRIPT ###
