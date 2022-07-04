get_latest_output <- function(folder_name, file_type = "csv") {
  file_pattern <- paste0("*.", file_type)
  all_files <- list.files(folder_name, pattern = file_pattern)
  latest_file <- sort(all_files, decreasing = TRUE)[1]
  file.path(folder_name, latest_file)
}
