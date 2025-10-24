#' Extract organisation prefix
#'
#' @param name Name of app (not URL)
#'
#' @return Character. Organisation prefix
#' @export
#'
#' @examples extract_org_prefix("sg-app")

extract_org_prefix <- function(name) {

  tolower(name) %>%
    stringr::word(1, sep = stringr::regex("[_-]"))

}
