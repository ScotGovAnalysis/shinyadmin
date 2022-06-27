library(openxlsx)
library(readr)
library(tibble)
library(dplyr)
library(stringr)
library(tidyr)


# Main table greyed row col definition ------------------------------------


# Read in latest csv result (find most recent file in outputs dir)
latest_result <- get_latest_output("outputs")

results_df <- read_csv(latest_result)

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
  col_names <- names(input_df)
  grep(column_name, col_names)
}

# Start of 'greyed out' rows by null app name
grey_row_start <- get_first_na(results_df, "name") + 1

# End of greyed out rows by df length
grey_row_end <- nrow(results_df) + 1

# Start of greyed out columns by column name
grey_column_start <- get_column_index(results_df, "app_title_readable")

# End of greyed columns == number of columns
grey_column_end <- ncol(results_df)


# Summary table -----------------------------------------------------------

# Counts of apps from server and from manual Google Sheet

count_server <- nrow(results_df %>% filter(!is.na(name)))
count_server <- tibble(Description = "Server total", App_Count = count_server)
count_manual <- nrow(read_csv("inputs/apps_catalogue.csv"))
count_manual <- tibble(Description = "(Manual spreadsheet)", App_Count = count_manual)

# Function to extract org name from app name using "org_" convention
extract_org_prefix <- function(input_url) {
  head(str_split(tail(str_split(input_url, "/")[[1]], 1), "-")[[1]], 1)
}

# Extract org from app name to new column
results_df <- results_df %>% mutate(org_extract = lapply(url, extract_org_prefix))

# If not known org, class as "not specified"
results_df <- results_df %>% mutate(org_extract = if_else(!org_extract %in% c("sg", "nrs", "nhs", "phs"), list("not specified"), org_extract))

# Summarise the extracted orgs
org_summary <- results_df %>%
  filter(!is.na(name)) %>%
  group_by(org_extract) %>%
  summarise(App_Count = n()) %>%
  unnest(org_extract)

# Make them uppper case and col names match for rbind
org_summary <- org_summary %>%
  rename(Description = org_extract) %>%
  mutate(Description = ifelse(Description != "not specified", str_to_upper(Description), Description))
org_summary <- as_tibble(org_summary)

# rbind all summary results
full_summary <- rbind(count_server, count_manual, org_summary)

# Use conversion to a factor for a specific sort order
full_summary <- full_summary %>%
  mutate(Description = factor(Description, levels = c("PHS", "SG", "NHS", "NRS", "not specified", "Server total", "(Manual spreadsheet)"))) %>%
  arrange(Description)

# Drop extracted name from results df
results_df <- results_df %>% select(-org_extract)

# writing to excel --------------------------------------------------------

# Rename some of the main table columns for clarity
results_df <- results_df %>% rename(app_url = url, hours_used_last_3_months = hours_used)

# Make openxlsx style for greyed rows / columns
grey_bg_style <- createStyle(fgFill = "#f0f2f5", border = "TopBottomLeftRight", borderColour = "#dadbdd")

# Set the url column to hyperlink excel type
class(results_df$app_url) <- "hyperlink"

# Set column names to title case
title_all_col_words <- function(column_name) {
  split_words <- str_split(column_name, "_")[[1]]
  split_words %>%
    str_to_title() %>%
    str_c(collapse = "_")
}

colnames(results_df) <- sapply(colnames(results_df), title_all_col_words)

# Create spreadsheet object and sheets
wb <- createWorkbook()

sheet_name <- "all_shiny_apps"

addWorksheet(wb, sheet_name)

addWorksheet(wb, "summary")

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
writeData(wb, sheet = "summary", x = full_summary, colNames = TRUE, startRow = 1, startCol = 1, headerStyle = bold_style)

# Save workbook
output_full_path <- str_replace(latest_result, ".csv", ".xlsx")
saveWorkbook(wb, output_full_path, overwrite = TRUE)
