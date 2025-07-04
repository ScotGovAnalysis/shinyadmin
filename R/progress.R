#' Progress bar for `purrr` functions
#'
#' @param name Progress bar name used in printed messages.
#'
#' @return List to be passed to `purrr` functions `.progress` argument.
#' @export
#'
#' @examples progress("Getting app visibility")

progress <- function(name) {
  
  list(
    name = name,
    format = paste0(
      "{cli::col_blue(cli::symbol$info)} ", 
      name, 
      ": {cli::pb_current}/{cli::pb_total}"
    ),
    format_done = paste(
      "{cli::col_green(cli::symbol$tick)}", 
      name, 
      "| Complete! [{cli::pb_elapsed}]"
    ),
    clear = FALSE
  )
  
}
