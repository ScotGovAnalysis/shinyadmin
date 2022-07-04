library(readr)
library(dplyr)
library(stringr)
library(tidyr)

source("R/hours_used.R")
source("R/number_of_connections.R")
source("R/app_visibility.R")
source("R/clean_manual_url.R")
source("R/clean_extracted_url.R")


# server application analysis ---------------------------------------------


# get all applications to dataframe
# Need to make sure connection is set in R Studio first, see README.md
df_applications <- rsconnect::applications()

# add mean hours, mean coonnections visibility to dataframe using custom functions
cat("Getting info per app from shinyapps.io. Please wait...")
df_applications <- mutate(df_applications,
  mean_hours_used = sapply(name, hours_used, back_months = 3),
  mean_connections = sapply(name, number_of_connections, back_months = 3),
  visibility = sapply(name, app_visibility)
)


# select columns to output
output_columns <- c("name", "url", "visibility", "created_time", "mean_hours_used", "mean_connections")

df_applications <- select(df_applications, all_of(output_columns))

# Sort desc by usage
df_applications <- arrange(df_applications, dplyr::desc(mean_hours_used))


# manually maintained record join -----------------------------------------


# Too much hassle to get googlesheets libraries with all their dependencies working. Download as CSV from
# https://docs.google.com/spreadsheets/d/1fUq57cX9AsRHUD_oWZV82Cp4Uk29WAhB8sQMTsNo_wE/edit#gid=2139199131
# into the repo inputs folder and read from there:
manual_record <- read_csv("inputs/apps_catalogue.csv")

# Clean google sheet column names
manual_record <- manual_record %>% rename(
  "timestamp" = "Timestamp",
  "email_address" = "Email address",
  "developer_name" = "Developer's name",
  "app_title_readable" = "App title (human readable title)",
  "app_link" = "App link (scotland.shinyapps.io/...)",
  "organisation" = "Organisation",
  "team" = "Team",
  "team_email_contact" = "Team's mailbox/other email of contact",
  "link_to_code" = "Link to code (if available)"
)

# Clean urls and then join on them

manual_record <- clean_manual_url(manual_record, url_column = "app_link")

# Order manual record columns
manual_record <- manual_record %>% select(app_title_readable, developer_name, email_address, organisation, team, team_email_contact, link_to_code, cleaned_url)


# Make cleaned column for server extract
df_applications <- clean_extracted_url(df_applications, url_column = "url")

# Full join by cleaned URLS
all_join_output <- df_applications %>% full_join(manual_record, by = c("url" = "cleaned_url"))


# organisation extract for manual review ----------------------------------

extract_org_prefix <- function(input_url) {
  input_url %>%
    str_split(pattern = "/") %>%
    extract2(1) %>%
    tail(1) %>%
    str_split("-") %>%
    extract2(1) %>%
    head(1) %>%
    if_else(!. %in% c("sg", "phs", "nrs", "nhs", "scotpho", "is", "snh"), "not specified", .)
}


all_join_output <- all_join_output %>% mutate(org_extract = sapply(url, extract_org_prefix))

org_review <- all_join_output %>% select(name, url, organisation, org_extract)

write_csv(org_review, "outputs/extracted_organisation_review.csv")


# Manually review the output csv and complete any "not specified" records
# Move the manually reviewed and edited csv to inputs and it will be read back in from there to update missing orgs
# NOTE: master copy of edited app vs organisation list should be in inputs

if (file.exists("inputs/extracted_organisation_review.csv")) {
  org_review <- read_csv("inputs/extracted_organisation_review.csv")
}

org_review <- org_review %>%
  rename(org_if_known = org_extract) %>%
  select(url, org_if_known)

all_join_output <- all_join_output %>%
  left_join(org_review, by = c("url")) %>%
  select(-org_extract)

# export final results csv ------------------------------------------------------

# Create output fp
output_full_path <- paste0("outputs/shiny_app_usage_", Sys.Date(), ".csv")

# Write to csv
write_csv(all_join_output, output_full_path)
