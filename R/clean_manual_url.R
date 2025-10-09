#' Clean free-text app URLs
#'
#' @param url Character vector of untidy free-text URLs
#' @inheritParams server_apps
#'
#' @return Character vector of clean URLs
#' @export
#'
#' @examples clean_manual_url("my_App")

clean_manual_url <- function(url, account = "scotland") {
  
  account <- tolower(account)
  
  new <- 
    url %>%
    stringr::str_to_lower() %>%
    stringr::str_remove_all(
      stringr::str_glue("(https?://)?{account}\\.shiny+apps\\.io/")
    ) %>%
    stringr::str_remove("/$") %>%
    stringr::str_remove("^/") %>%
    stringr::str_remove_all("\\n") %>%
    stringr::str_remove_all("\\s") %>%
    stringr::str_remove_all("<?>?")
  
  dplyr::case_when(
    stringr::str_detect(new, stringr::str_glue("^https://")) ~ new,
    new == "" ~ NA_character_,
    .default = stringr::str_glue("https://{account}.shinyapps.io/{new}")
  )
  
}
