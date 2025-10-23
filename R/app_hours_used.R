#' Total hours of app usage
#'
#' @inheritParams server_apps
#' @param back_months Number of months in the past to include app usage data.
#' Maximum value is 3.
#'
#' @examples
#' \dontrun{app_hours_used(back_months = 1)}

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

  dplyr::tibble(usage = usage["points"]) %>%
    tidyr::unnest_longer(usage, indices_to = "app_id") %>%
    tidyr::unnest_longer(usage) %>%
    tidyr::unnest_wider(usage, names_sep = "_") %>%
    dplyr::rename(hours = .data$usage_2) %>%
    dplyr::mutate(
      app_id = as.numeric(stringr::str_remove(.data$app_id, "^application-"))
    ) %>%
    dplyr::group_by(.data$app_id) %>%
    dplyr::summarise(total_hours = sum(.data$hours), .groups = "drop")

}
