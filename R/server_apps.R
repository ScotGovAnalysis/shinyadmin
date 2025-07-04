#' List deployed Shiny Server apps
#' 
#' @details Note that including additional data (e.g. visibility data) will 
#' mean the function takes longer to run.
#'
#' @param account Name of Shiny Server account where app is deployed.
#' @param visibility Logical: Should app visibility data be included?
#'
#' @return Tibble.
#' @export
#'
#' @examples server_apps()

server_apps <- function(account = "scotland", 
                        visibility = TRUE) {
  
  cli::cli_progress_step(
    msg = "Getting server apps",
    msg_done = "Getting server apps | Complete!"
  )
  
  apps <- rsconnect::applications(account = account)
  
  cli::cli_progress_done()
  
  if (visibility) {
    apps <- apps %>% dplyr::mutate(visibility = app_visibility(name, account))
  }
  
  tibble::as_tibble(apps)
  
}
