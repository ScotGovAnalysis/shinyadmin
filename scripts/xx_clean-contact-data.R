# Name: xx_clean-contact-data.R
# Description: Clean contact data from MS Form and save to ADM


# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Read raw data from MS Form excel file ----

contacts <- 
  read_xlsx(config$ms_form_path) %>%
  rename_cols(lookups$ms_form_names) %>%
  select(-starts_with("ms")) %>%
  mutate(completed_time = ymd_hms(completed_time),
         across(!matches("time"), as.character))


# 2 - Write data to ADM ----

write_dataframe_to_db(
  config$adm_server,
  config$database,
  config$schema,
  table_name = "contacts_new",
  dataframe = contacts
)


### END OF SCRIPT ###