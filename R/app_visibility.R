#' Determine whether app is public or private
#'
#' @param app_name Name of the app on the Shiny Server.
#'
#' @return chatacter string of "public" or "private".
#'
#' @examples
#' get_visibiity("my_app")
app_visibility <- function(app_name) {
  tryCatch(
    {
      all_properties <- rsconnect::showProperties(appName = app_name)
      all_properties["application.visibility", ][1]
    },
    error = function(e) {
      "Not available"
    }
  )
}
