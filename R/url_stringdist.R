#' Get string distance between URLs
#'
#' @param url Character vector of URLs.
#'
#' @return A tibble containing URL pairs with a distance less than 7.
#' @export
#'
#' @examples 
#' url_stringdist(c("https://scotland.shinyapps.io/my-app",
#'                  "https://scotland.shinyapps.io/my-app2",
#'                  "https://scotland.shinyapps.io/another-name",
#'                  "https://scotland.shinyapps.io/my-new-app"))

url_stringdist <- function(url) {

  stringdist::stringdistmatrix(url, url, useNames = "strings") %>%
    dplyr::as_tibble(rownames = "url1") %>%
    tidyr::pivot_longer(!url1, names_to = "url2", values_to = "dist") %>%
    dplyr::filter(url1 != url2 & dist < 7) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(url = list(sort(c(url1, url2)))) %>%
    dplyr::ungroup() %>%
    dplyr::distinct(url, .keep_all = TRUE) %>%
    dplyr::select(-url)
  
}
