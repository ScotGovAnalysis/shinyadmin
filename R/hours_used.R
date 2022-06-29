#' Sum app usage in hours
#'
#' @param app_name Name of the app in the Shiny Server.
#' @param back_months Go back this many months from the present date when calc usage (1 to 3 as only recorded up to 3 months).
#'
#' @examples
#' get_hours_used("my_test_app", back_months1)
hours_used <- function(app_name, back_months = 3) {
  until_date <- as.Date(Sys.Date())
  from_date <- as.Date(Sys.Date()) - lubridate:::months.numeric(back_months)
  tryCatch(
    {
      mean(rsconnect::showUsage(appName = app_name, from = from_date, until = until_date)[["hours"]])
    },
    error = function(e) {
      0
    }
  )
}