# Name: 05_produce-reports.R
# Description: Produce xlsx data file and dashboard


# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Read analysis table ----

analysis <-
  read_table_from_db(
    config$adm_server,
    config$database,
    config$schema,
    "analysis"
  )

record_date <- unique(analysis$record_date)


# 2 - Write Excel file ----

analysis %>%
  excel_output(org_group = "all") %>%
  write_xlsx(
    here("outputs", paste0(record_date, "_shiny-apps.xlsx")),
    format_headers = FALSE
  )


# 3 - Render Quarto dashboard ----

render_dashboard(
  here("scripts", "dashboard", "dashboard.qmd"),
  here("outputs", paste0(record_date, "_shinyadmin.html"))
)


### END OF SCRIPT ###
