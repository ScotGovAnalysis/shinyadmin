get_latest_output <- function(folder_name, file_type = "csv", file_prefix="shiny_app_usage") {
  file_pattern <- paste0("*.", file_type)
  all_files <- list.files(folder_name, pattern = file_pattern)
  filtered_files <- all_files[grepl(file_prefix, all_files)]
  latest_file <- sort(filtered_files, decreasing = TRUE)[1]
  file.path(folder_name, latest_file)
}
