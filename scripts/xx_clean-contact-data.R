# Name: xx_clean-contact-data.R
# Description: Clean contact data from MS Form and save to ADM

# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Read raw data from MS Form excel file ----

contacts <- 
  read_xlsx(config$ms_form_path) %>%
  rename_cols(lookups$ms_form_names)


### END OF SCRIPT ###