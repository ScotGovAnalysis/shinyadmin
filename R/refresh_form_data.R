#' Refresh Microsoft Form data file
#'
#' @description The Microsoft Form to collect contact information is linked to
#'   an Excel spreadsheet where results are stored. However, the spreadsheet
#'   does not automatically update with new form responses (this is expected
#'   behaviour for MS Forms).
#'
#'   This function is used to open the spreadsheet in a browser, allow time for
#'   the online version to update and for the local version to sync.
#'
#' @param link Character string. Shared link to OneDrive data file containing
#'   Microsoft Form responses.
#'
#' @param wait Numeric. Number of seconds to wait to allow for local data file
#'   to sync with OneDrive file. Defaults to 60.
#'
#' @details If the value supplied to `link` doesn't exist or is an empty string,
#'   the function will print a message and stop, but not produce an error.
#'
#'   The function does not check the validity of `link`. If invalid, the browser
#'   will not open, but the function will continue to wait.
#'
#'   Running this function does not guarantee that the file will be refreshed.
#'   The value provided to `wait` is arbitrary, and the user should make sure
#'   this is long enough for the file to refresh in their working environment.
#'
#' @return `TRUE` (invisibly)
#' @export
#'
#' @examples refresh_form_data("x", wait = 10)

refresh_form_data <- function(link, wait = 60) {

  skip <- function() {
    cli::cli_inform(c("i" = "No link found. Skipping refresh..."))
    invisible(NULL)
  }

  if (length(link) == 0) return(skip())
  if (link == "") return(skip())

  utils::browseURL(link)

  cli::cli_progress_bar(
    total = wait,
    format = paste(
      "{cli::col_cyan(cli::symbol$info)} Waiting for data file to refresh...",
      "{wait - t}s remaining"
    ),
    format_done = "{cli::col_green(cli::symbol$tick)} Done!",
    clear = FALSE
  )

  for (t in 1:wait) {
    Sys.sleep(1)
    cli::cli_progress_update()
  }

  invisible(TRUE)

}
