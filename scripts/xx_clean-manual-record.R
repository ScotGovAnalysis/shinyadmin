# Name: xx_clean-manual-record.R
# Description: This code is used to clean the raw data from the old Google form.
# This form doesn't exist anymore, so this code shouldn't need to be run again 
# in the future.


# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Read and clean Google survey data ----

google <- 
  
  read_csv(here("inputs", "2024-07-16_google-record.csv")) %>%
  
  # Remove empty columns (read_csv gives name in format ...1)
  select(-matches("^\\.\\.\\.\\d+$")) %>% 
  
  # Rename and reorder columns
  select(
    date = "Timestamp",
    app_name = "App title (human readable title)",
    url = "App link (scotland.shinyapps.io/...)",
    org = "Organisation",
    dev_name = "Developer's name",
    dev_email = "Email address",
    team_name = "Team",
    team_email = "Team's mailbox/other email of contact",
    code_url = "Link to code (if available)"
  ) %>%
  
  # Format date
  mutate(date = dmy_hms(date)) %>%
  
  # Clean URLs
  separate_longer_delim(cols = url, delim = regex("\\nto be changed to\\s")) %>%
  mutate(url = clean_manual_url(url)) %>%
  
  # Clean organisation
  mutate(
    org = org %>%
      str_replace_all("Heath", "Health") %>%
      str_replace_all("^NHS Health Scotland$", "Public Health Scotland") %>%
      str_replace_all("^NHS National Services Scotland$", 
                      "Public Health Scotland")
  ) %>%
  
  # Remove duplicates where later record submitted
  group_by(url) %>%
  filter(n() == 1 | date == max(date)) %>%
  ungroup()


# 2 - Correct invalid app URLs ----

missing_urls <- 
  google %>%
  filter(is.na(url)) %>%
  separate_longer_delim(cols = app_name, delim = regex("\\s&\\s")) %>%
  mutate(url = case_when(
    is.na(url) ~ paste0("https://scotland.shinyapps.io/", app_name),
    TRUE ~ url
  ))

google <- 
  google %>%
  filter(!is.na(url)) %>%
  bind_rows(missing_urls)

invalid_url_path <- here("lookups", "invalid-urls.csv")

if (file.exists(invalid_url_path)) {
  
  invalid_urls <- 
    google %>% 
    filter(!str_starts(url, "https://scotland.shinyapps.io/")) %>%
    left_join(read_csv(invalid_url_path), 
              by = join_by(url == invalid_url)) %>%
    mutate(url = valid_url) %>%
    select(-valid_url)
  
  google <-
    google %>%
    filter(str_starts(url, "https://scotland.shinyapps.io/")) %>%
    bind_rows(invalid_urls)
  
}


# 3 - Save clean dataset ----

write_dataframe_to_db(
  config$adm_server,
  config$database,
  config$schema,
  table_name = "contacts_old",
  dataframe = google
)


### END OF SCRIPT ###