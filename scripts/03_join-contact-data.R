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
  mutate(url = clean_manual_url(url)) %>%
  select(-response_id)


# Consolidate 'accepted' organisations into 1 column (`org`)

accept_orgs <- orgs %>% filter(ms_form_accepted)

contacts_new <-
  contacts_new %>%
  mutate(
    org =
      case_when(
        str_detect(org_other, "NatureScot") ~ "NatureScot",
        org_other %in% accept_orgs$org_name ~ org_other,
        .default = org
      ) %>%
      str_remove("\\s\\(.*\\)$"),
    org_other = if_else(org == "Other", org_other, NA_character_)
  )

rm(accept_orgs)


# Flag 'other' organisations for manual review

orgs_to_review <-
  contacts_new %>%
  filter(!is.na(org_other)) %>%
  arrange(org_other) %>%
  relocate(org_other, url, .before = 0)

if (nrow(orgs_to_review) > 0) {
  cli_inform(c(
    "!" = paste("{n_distinct(orgs_to_review$org_other)} organisation{?s}",
                "{?is/are} not in the expected list."),
    "i" = "View the {.code orgs_to_review} data frame to review.",
    "i" = paste("If the organisation should be accepted, add it to",
                "{.file data-raw/orgs.R}.")
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
