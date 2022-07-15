library(magrittr) # For pipe (#' @importFrom magrittr %>%)

clean_manual_url <- function(input_df, url_column, url_root = "https://scotland.shinyapps.io/") {
  input_df %>%
    # Remove root url as some have some omit
    dplyr::mutate(cleaned_url = stringr::str_replace(.data[[url_column]], url_root, "")) %>%
    # However some are non-shiny.io urls, need to keep as are
    dplyr::mutate(cleaned_url = dplyr::if_else(!grepl("http", cleaned_url), stringr::str_c(url_root, cleaned_url), cleaned_url)) %>%
    # Some have two urls in one cell separated by "to be changed to" - split them onto separate lines
    dplyr::mutate(cleaned_url = strsplit(cleaned_url, "to be changed to")) %>%
    tidyr::unnest(cleaned_url) %>%
    # Perform the above fixing over non- urls again following new line split
    dplyr::mutate(cleaned_url = dplyr::if_else(!grepl("http", cleaned_url), stringr::str_c(url_root, cleaned_url), cleaned_url)) %>%
    # Remove any whitespace
    dplyr::mutate(cleaned_url = stringr::str_replace_all(cleaned_url, " ", "")) %>%
    # Make lower case
    dplyr::mutate(cleaned_url = stringr::str_to_lower(cleaned_url)) %>%
    # Remove any newline characters and trailing /
    dplyr::mutate(cleaned_url = stringr::str_replace_all(cleaned_url, "(\\n|/$)", ""))
}
