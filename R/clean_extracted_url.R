library(magrittr) # For pipe (#' @importFrom magrittr %>%)

clean_extracted_url <- function(input_df, url_column) {
  input_df %>%
    mutate(url = str_to_lower(.data[[url_column]])) %>%
    mutate(url = str_replace_all(.data[[url_column]], "/$", ""))
}
