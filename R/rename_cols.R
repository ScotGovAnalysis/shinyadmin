rename_cols <- function(df, names_lookup) {
  
  if (any(!c("new", "old") %in% names(names_lookup))) {
    cli::cli_abort(
      "`names_lookup` must contain columns named \"new\" and \"old\"."
    )
  }
  
  missing <- setdiff(names(df), names_lookup$old)
  
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "x" = "One or more variable names are missing from `names_lookup`.\n",
      "i" = "Missing names: {.str {missing}}."
    ))
  }
  
  df %>%
    dplyr::rename(!!!tibble::deframe(names_lookup))
  
}
