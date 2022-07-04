library(openxlsx)
library(readr)
library(tibble)
library(dplyr)
library(stringr)
library(tidyr)
library(magrittr)

# Main table greyed row col definition ------------------------------------


# Read in latest csv result (find most recent file in outputs dir)
latest_result <- get_latest_output("outputs")

results_df <- read_csv(latest_result)


# Summary table -----------------------------------------------------------

# Read and join org acronym to description lookup

org_lookup <- read_csv("organisation_lookup.csv")

results_df <- results_df %>%
  left_join(org_lookup, by = c("org_if_known" = "org_acronym")) %>%
  rename(organisation_name = org_description) %>%
  mutate(organisation_name = if_else(is.na(organisation_name), "not known", organisation_name))


# Counts of apps from server and from manual Google Sheet

# Summarise the extracted orgs
org_summary <- results_df %>%
  filter(!is.na(name) & organisation_name != "not known") %>%
  group_by(organisation_name) %>%
  summarise(App_Count = n()) %>%
  arrange(desc(App_Count))

org_summary_unknown <- results_df %>%
  filter(!is.na(name) & organisation_name == "not known") %>%
  group_by(organisation_name) %>%
  summarise(App_Count = n())

org_summary <- bind_rows(org_summary, org_summary_unknown)



# fix output column names -------------------------------------------------

results_df <- results_df %>% select(
  name,
  url,
  organisation_name,
  visibility,
  created_time,
  mean_hours_used,
  mean_connections,
  app_title_readable,
  developer_name,
  email_address,
  organisation,
  team,
  team_email_contact,
  link_to_code
)

# Rename some of the main table columns for clarity
results_df <- results_df %>% rename(
  app_url = url,
  mean_active_hours_per_day = mean_hours_used,
  mean_daytime_connections = mean_connections,
  organisation_manual_input = organisation
)


# Set column names to title case
title_all_col_words <- function(column_name) {
  split_words <- str_split(column_name, "_")[[1]]
  split_words %>%
    str_to_title() %>%
    str_c(collapse = "_")
}

colnames(results_df) <- sapply(colnames(results_df), title_all_col_words)

colnames(org_summary) <- sapply(colnames(org_summary), title_all_col_words)


# grey row column positions -----------------------------------------------

# Get row index of first NA row
get_first_na <- function(input_df, column_name) {
  filtered_df <- input_df %>%
    rowid_to_column() %>%
    filter(is.na(.data[[column_name]])) %>%
    head(1) %>%
    .[["rowid"]]
}

# Get column index of specified column name
get_column_index <- function(input_df, column_name) {
  col_names <- colnames(input_df)
  grep(column_name, col_names)
}

# Start of 'greyed out' rows by null app name
grey_row_start <- get_first_na(results_df, "Name") + 1

# End of greyed out rows by df length
grey_row_end <- nrow(results_df) + 1

# Start of greyed out columns by column name
grey_column_start <- get_column_index(results_df, "App_Title_Readable")

# End of greyed columns == number of columns
grey_column_end <- ncol(results_df)

# Populate no app name rows with No LONGER ON scotland.shinyapps.io
results_df <- results_df %>% mutate(Name = ifelse(is.na(Name), "NO LONGER ON scotland.shinyapps.io", Name))

# writing to excel --------------------------------------------------------


# Make openxlsx style for greyed rows / columns
grey_bg_style <- createStyle(fgFill = "#f0f2f5", border = "TopBottomLeftRight", borderColour = "#dadbdd")

# Set the url column to hyperlink excel type
class(results_df$App_Url) <- "hyperlink"


# Create spreadsheet object and sheets
wb <- createWorkbook()

sheet_name <- "all_shiny_apps"

addWorksheet(wb, sheet_name)

addWorksheet(wb, "summary_by_org")

# Create a bold style for column headers

bold_style <- createStyle(textDecoration = "Bold")

bold_grey <- createStyle(textDecoration = "Bold", border = "TopBottomLeftRight", fgFill = "#f0f2f5", borderColour = "#dadbdd")

# Write the main df and set grey style areas

writeData(wb, sheet = sheet_name, x = results_df, startRow = 1, startCol = 1, headerStyle = bold_style)

addStyle(wb, sheet_name, grey_bg_style, rows = grey_row_start:grey_row_end, cols = 1:grey_column_end, gridExpand = TRUE)

addStyle(wb, sheet_name, grey_bg_style, rows = 1:grey_row_end, cols = grey_column_start:grey_column_end, gridExpand = TRUE)

addStyle(wb, sheet_name, bold_grey, rows = 1:1, cols = grey_column_start:grey_column_end, gridExpand = TRUE)

# Auto fix columns to data
setColWidths(wb, sheet = sheet_name, cols = 1:length(names(results_df)), widths = "auto")

# Write summary table
writeData(wb, sheet = "summary_by_org", x = org_summary, colNames = TRUE, startRow = 1, startCol = 1, headerStyle = bold_style)

# Save workbook
output_full_path <- str_replace(latest_result, ".csv", ".xlsx")
saveWorkbook(wb, output_full_path, overwrite = TRUE)
