library(dplyr)
library(plotly)
library(readr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

source("../R/all_hours_used.R") #Function to extracted active hours per app
source("../R/get_latest_output.R") #Function to get latest shiny_app_usage csv

# Read existing summary output in order to get app names ---------------------

# NOTE: Must run ../get_app_info.R to generate this output first.

latest_result <- get_latest_output("../outputs")

summary_df <- read_csv(latest_result)

apps_to_test <- summary_df$name


# Get daily active hours per app ------------------------------------------


results_list <- list()

for (app in apps_to_test){
  results_list[[app]] <- get_all_active_hours(app)
}

results_df <- bind_rows(results_list)


# Clean df columns ---------------------------------------


results_df$timestamp <- as.numeric(results_df$timestamp)

results_df$timestamp <- as.POSIXct(results_df$timestamp, origin= as.Date("1970-01-01"))

results_df$date <- as.Date(results_df$timestamp)

results_df <- results_df %>% select(-timestamp)


# Write output ------------------------------------------------------------

write_csv(results_df, paste0("../outputs/apps_full_activity_", Sys.Date(), ".csv"))
