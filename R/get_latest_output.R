#' Get latest dated file in folder
#'
#' @param file_base_name Base name of files to search. Full expected file name
#' format is YYYY-MM-DD_<file_base_name>.rds
#' @param folder_name File path to directory to search. 
#' Defaults to `here::here("outputs")`
#' @param file_ext Defaults to "rds".
#'
#' @return Character string if file exists.
#' @export
#'
#' @examples get_latest_output(here("outputs"), "manual-record", "rds")

get_latest_output <- function(file_base_name, 
                              folder_name = here::here("outputs"),
                              file_ext = "rds") {
  
  list.files(folder_name,
             pattern = paste0("*_", file_base_name, ".", file_ext, "$"),
             full.names = TRUE) %>%
    sort(decreasing = TRUE) %>%
    magrittr::extract(1)

}
