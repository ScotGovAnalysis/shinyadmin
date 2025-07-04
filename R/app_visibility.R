#' Determine whether app is public or private
#'
#' @param app_name Character vector of names of apps on the Shiny Server.
#' @inheritParams server_apps
#'
#' @return Character vector of "public" or "private".
#'
#' @examples
#' app_visibility("my_app")

app_visibility <- function(app_name, account = "scotland") {
  
  app_name %>%
    purrr::map(
      \(x) {
        tryCatch(
          {
            rsconnect::showProperties(appName = x, account = account) %>%
              magrittr::extract("application.visibility", 1)
          },
          error = \(e) NA_character_
        )
      },
      .progress = progress("Getting app visibility data")
    ) %>%
    purrr::list_c()
  
}
