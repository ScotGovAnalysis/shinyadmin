# Name: 05_produce-reports.R
# Description: Produce xlsx data file and dashboard


# 0 - Run setup script ----

source(here::here("scripts", "00_setup.R"))


# 1 - Write Excel file ----

excel <-
  read_table_from_db(
    config$adm_server,
    config$database,
    config$schema,
    "analysis"
  ) %>%
  excel_output(org_group = "all")

write_xlsx(
  excel,
  here("outputs", paste0(Sys.Date(), "_shiny-apps.xlsx")),
  format_headers = FALSE
)


# 2 - Render Quarto dashboard ----

render_dashboard(
  here("scripts", "dashboard", "dashboard.qmd"),
  here("outputs", paste0(Sys.Date(), "_shinyadmin.html"))
)


### END OF SCRIPT ###
