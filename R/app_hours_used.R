#' Total hours of app usage
#'
#' @inheritParams app_visibility
#' @param back_months Number of months in the past to include app usage data.
#' Maximum value is 3.
#'
#' @examples
#' app_hours_used("my_app", back_months = 1)

app_hours_used <- function(app_name, account = "scotland", back_months = 3) {
  
  if (!back_months %in% 1:3) {
    cli::cli_abort(
      "{.arg back_months} must be either 1, 2 or 3."
    )
  }
  
  app_name %>%
    purrr::map(
      \(x) {
        tryCatch(
          {
            rsconnect::showUsage(appName = x, 
                                 account = account,
                                 from = Sys.Date() %m-% months(back_months), 
                                 until = Sys.Date()) %>%
              dplyr::pull(hours) %>%
              sum()
          },
          error = \(e) 0
        )
      },
      .progress = progress("Getting hours used data")
    ) %>%
    purrr::list_c()
  
}

