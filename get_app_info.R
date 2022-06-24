library(readr)
library(dplyr)
library(stringr)
library(tidyr)

source("R/hours_used.R")
source("R/app_visibility.R")
source("R/clean_manual_url.R")
source("R/clean_extracted_url.R")

# get all applications to dataframe
# Need to make sure connection is set in R Studio first, see README.md
df_applications <- rsconnect::applications()

# add hours used to dataframe using custom function
df_applications <- mutate(df_applications, hours_used = sapply(name, hours_used, back_months=3))

# add the visbility of the app whether public or private using custom function
df_applications <- mutate(df_applications, visibility = sapply(name, app_visibility))

# select columns to output
output_columns <- c("name", "url", "visibility", "created_time", "hours_used") 

df_applications <- select(df_applications, all_of(output_columns))

# Sort desc by usage
df_applications <- arrange(df_applications, dplyr::desc(hours_used)) 


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

manual_record <- clean_manual_url(manual_record, url_column="app_link")


# Make cleaned column for server extract
df_applications <- clean_extracted_url(df_applications, url_column="url")

# Full join by cleaned URLS
all_join_output <- server_extract %>% full_join(manual_record, by = c("url" = "cleaned_url"))

# Create output fp
output_full_path <- paste0("outputs/shiny_app_usage_", Sys.Date(), ".csv")

# Write to csv
write_csv(all_join_output, output_full_path)

