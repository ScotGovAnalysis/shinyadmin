# Name: 01_snapshot-server-data.R
# Description: Take a snapshot of app data from shinyapps.io and write to ADM


# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Get app data from server ----

apps <- server_apps("scotland",
                    visibility = FALSE,
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
