library(openxlsx)
library(readr)
library(tibble)

latest_result <- get_latest_output("outputs")

test_df <- read_csv(latest_result)

get_first_na <- function(input_df, column_name) {
  filtered_df <- input_df %>%
    rowid_to_column() %>%
    filter(is.na(.data[[column_name]])) %>%
    head(1) %>%
    .[["rowid"]]
}

get_column_index <- function(input_df, column_name) {
  col_names <- names(input_df)
  grep(column_name, col_names)
}

grey_row_start <- get_first_na(test_df, "name") + 1

grey_row_end <- nrow(test_df) + 1

grey_column_start <- get_column_index(test_df, "app_title_readable")

grey_column_end <- ncol(test_df)

grey_bg_style <- createStyle(fgFill = "#f0f2f5", border = "TopBottomLeftRight", borderColour = "#dadbdd")

class(test_df$url) <- "hyperlink"

wb <- createWorkbook()

sheet_name <- "all_shiny_apps"

addWorksheet(wb, sheet_name)

bold_style <- createStyle(textDecoration = "Bold")

bold_grey <- createStyle(textDecoration = "Bold",  border = "TopBottomLeftRight", fgFill = "#f0f2f5", borderColour = "#dadbdd")

writeData(wb, sheet = sheet_name, x = test_df, startRow = 1, startCol = 1, headerStyle = bold_style)

addStyle(wb, sheet_name, grey_bg_style, rows = grey_row_start:grey_row_end, cols = 1:grey_column_end, gridExpand = TRUE)

addStyle(wb, sheet_name, grey_bg_style, rows = 1:grey_row_end, cols = grey_column_start:grey_column_end, gridExpand = TRUE)

addStyle(wb, sheet_name, bold_grey, rows = 1:1, cols = grey_column_start:grey_column_end, gridExpand = TRUE)

setColWidths(wb, sheet = sheet_name, cols = 1:length(names(test_df)), widths = "auto")

count_server <- nrow(test_df %>% filter(!is.na(name)))
count_server <- data.frame(desc=c("server_extract_total"), count=count_server)
count_manual <- nrow(read_csv("inputs/apps_catalogue.csv"))
count_manual <- data.frame(desc=c("manual_spreadsheet"), total=c(count_manual))

extract_org_prefix <- function(input_url) {
  head(str_split(tail(str_split(input_url, "/")[[1]], 1), "-")[[1]], 1)
}

test_df <- test_df %>% mutate(org_extract = lapply(url, extract_org_prefix))

test_df <- test_df %>% mutate(org_extract = if_else(!org_extract %in% c("sg", "nrs", "nhs", "phs"), list("not specified"), org_extract))

org_summary <- test_df %>%
  filter(!is.na(name)) %>%
  group_by(org_extract) %>%
  summarise(app_count = n())

org_summary <- org_summary %>%
  rename(org_name_extracted = org_extract) %>%
  mutate(org_name_extracted = ifelse(org_name_extracted != "not specified", str_to_upper(org_name_extracted), org_name_extracted)) %>%
  mutate(org_name_extracted = factor(org_name_extracted, levels=c("PHS", "SG", "NHS", "NRS", "not specified"))) %>%
  arrange(org_name_extracted)

addWorksheet(wb, "summary")
writeData(wb, sheet="summary", x= count_server, colNames=TRUE, startRow=1, startCol=1)
writeData(wb, sheet="summary", x= org_summary, colNames=FALSE, startRow=3, startCol=1)
writeData(wb, sheet="summary", x= count_manual, colNames=FALSE, startRow=4, startCol=1)



saveWorkbook(wb, "outputs/test_result.xlsx", overwrite = TRUE)
