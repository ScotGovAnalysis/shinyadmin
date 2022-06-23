library(readr)
library(dplyr)
library(stringr)
library(tidyr)

get_latest_output <- function(folder_name, file_type = "csv") {
  file_pattern <- paste0("*.", file_type)
  all_files <- list.files(folder_name, pattern = file_pattern)
  latest_file <- sort(all_files, decreasing = TRUE)[1]
  file.path(folder_name, latest_file)
}

# Out of get_app_info.R in this repo
latest_output <- get_latest_output("outputs")
server_extract <- read_csv(latest_output)

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

root_url <- "https://scotland.shinyapps.io/"

# Make cleaned column for manual record urls
manual_record <- manual_record %>%
  mutate(cleaned_url = str_replace(app_link, root_url, "")) %>%
  mutate(cleaned_url = if_else(!grepl("http", cleaned_url), str_c(root_url, cleaned_url), cleaned_url)) %>%
  mutate(cleaned_url = strsplit(cleaned_url, "to be changed to")) %>%
  unnest(cleaned_url) %>%
  mutate(cleaned_url = if_else(!grepl("http", cleaned_url), str_c(root_url, cleaned_url), cleaned_url)) %>%
  mutate(cleaned_url = str_replace_all(cleaned_url, " ", "")) %>%
  mutate(cleaned_url = str_to_lower(cleaned_url)) %>%
  mutate(cleaned_url = str_replace_all(cleaned_url, "(\\n|/$)", ""))


# Make cleaned column for server extract
server_extract <- server_extract %>%
  mutate(url = str_to_lower(url)) %>%
  mutate(url = str_replace_all(url, "(\\n|/$)", ""))

# Full join by cleaned URLS
all_join_output <- server_extract %>% full_join(manual_record, by = c("url" = "cleaned_url"))

#Write joined output to csv
write_csv(all_join_output, "outputs/server_manual_join.csv")
