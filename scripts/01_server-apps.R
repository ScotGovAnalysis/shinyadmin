# Name: 01_server-apps.R
# Description: Extract app data from shinyapps.io


# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Get app data from server ----

apps <- server_apps("scotland", 
                    visibility = TRUE, 
                    hours_used = TRUE)


# 2 - Write data to ADM ----

write_dataframe_to_db(
  config$adm_server,
  config$database,
  config$schema,
  table_name = "server_apps",
  dataframe = apps
)


### END OF SCRIPT ###