#' Get latest dated file in folder
#'
#' @param folder_name File path to directory to search
#' @param file_base_name Base name of files to search. Full expected file name
#' format is YYYY-MM-DD_<file_base_name>.rds
#' @param file_ext Defaults to "rds".
#'
#' @return Character string if file exists.
#' @export
#'
#' @examples get_latest_output(here("outputs"), "manual-record", "rds")

get_latest_output <- function(folder_name, file_base_name, file_ext = "rds") {
  
  list.files(folder_name,
             pattern = paste0("*_", file_base_name, ".", file_ext, "$"),
             full.names = TRUE) %>%
    sort(decreasing = TRUE) %>%
    magrittr::extract(1)

}
