#' Remove dates from URLs
#'
#' @param url Character vector of URLs
#'
#' @return Character vector
#' @export
#'
#' @examples url_remove_dates("https://scotland.shinyapps.io/my-app_feb25")

url_remove_dates <- function(url) {
  
  url %>%
    stringr::str_remove("-\\d{2}-\\d{2}-\\d{4}$") %>%
    stringr::str_remove("(-\\d{4}){1,2}$") %>%
    stringr::str_remove("-\\d{4}-?\\d{2}(-PRA)?$") %>%
    stringr::str_remove(paste0("[_-](", 
                               paste(month.name, collapse = "|"), "|",
                               paste(tolower(month.name), collapse = "|"),
                               ")[_-]\\d{2}$")) %>%
    stringr::str_remove(paste0("[_-](", 
                               paste(tolower(month.abb), collapse = "|"),
                               ")[_-]?\\d{2,4}$")) %>%
    stringr::str_remove("([_-]\\d){1,2}$")
  
}
