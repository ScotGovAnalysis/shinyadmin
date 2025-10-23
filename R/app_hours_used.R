#' Total hours of app usage
#'
#' @inheritParams server_apps
#' @param back_months Number of months in the past to include app usage data.
#' Maximum value is 3.
#'
#' @examples
#' app_hours_used(back_months = 1)

app_hours_used <- function(account = "scotland", back_months = 3) {
  
  if (!back_months %in% 1:3) {
    cli::cli_abort(
      "{.arg back_months} must be either 1, 2 or 3."
    )
  }
  
  usage <-
    rsconnect::accountUsage(
      account, 
      from = Sys.Date() - months(back_months), 
      until = Sys.Date()
    )
  
  tibble(usage = usage["points"]) %>%
    unnest_longer(usage, indices_to = "app_id") %>%
    unnest_longer(usage) %>%
    unnest_wider(usage, names_sep = "_") %>%
    rename(hours = usage_2) %>%
    mutate(
      app_id = as.numeric(str_remove(app_id, "^application-"))
    ) %>%
    group_by(app_id) %>%
    summarise(total_hours = sum(hours), .groups = "drop")
  
}
