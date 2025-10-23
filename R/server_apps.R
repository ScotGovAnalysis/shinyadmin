#' List deployed Shiny Server apps
#'
#' @details Note that including additional data (e.g. visibility data) will
#' mean the function takes longer to run.
#'
#' @param account Name of Shiny Server account where app is deployed.
#' @param visibility Logical: Should app visibility data be included?
#' @param hours_used Logical: Should hours used data be included?
#' @inheritParams app_hours_used
#'
#' @return Tibble.
#' @export
#'
#' @examples \dontrun{server_apps()}

server_apps <- function(account = "scotland",
                        visibility = FALSE,
                        hours_used = FALSE,
                        back_months = 3) {

  # Check account exists
  if(!account %in% rsconnect::accounts()$name) {
    cli::cli_abort(
      "{.val {account}} account not registered in RStudio.\n",
      "Use `rsconnect::setAccountInfo() to register before proceeding."
    )
  }

  cli::cli_progress_step(
    msg = "Getting server apps",
    msg_done = "Getting server apps | Complete!"
  )

  apps <-
    rsconnect::applications(account = account) %>%
    dplyr::mutate(
      dplyr::across(dplyr::contains("time"), lubridate::ymd_hms),
      url = stringr::str_remove(.data$url, "/$") %>%
        stringr::str_to_lower()
    ) %>%
    dplyr::select(-dplyr::all_of(c("instances", "guid", "title")))

  cli::cli_progress_done()

  if (visibility) {
    apps <- apps %>% dplyr::mutate(visibility = app_visibility(.data$name, account))
  }

  if (hours_used) {
    cli::cli_progress_step(
      msg = "Getting hours used data",
      msg_done = "Getting hours used data | Complete!"
    )
    hours <- app_hours_used(account, back_months)
    apps <- apps %>%
      dplyr::left_join(hours,
                       by = dplyr::join_by("id" == "app_id")) %>%
      dplyr::mutate(total_hours = tidyr::replace_na(.data$total_hours, 0))
    cli::cli_progress_done()
  }

  tibble::as_tibble(apps) %>%
    dplyr::select(-.data$id) %>%
    dplyr::mutate(record_date = lubridate::today(tzone = "UTC"),
                  .before = 0)

}
