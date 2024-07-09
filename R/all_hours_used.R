all_hours_used <- function(app_name, back_months = 3) {
  until_date <- as.Date(Sys.Date())
  from_date <- as.Date(Sys.Date()) - lubridate:::months.numeric(back_months)
  tryCatch(
    {
      extracted_df <- rsconnect::showUsage(appName = app_name, from = from_date, until = until_date)
      extracted_df$app_name <- app_name
      extracted_df
    },
    error = function(e) {}
  )
}
