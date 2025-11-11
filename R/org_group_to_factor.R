#' Convert grouped organisation data to factor (for sorting)
#'
#' @param org_group Character vector of grouped organisations.
#' See Details for accepted values.
#'
#' @details Accepted values in `org_group`:
#' * Scottish Government (inc. agencies)
#' * Public Health Scotland
#' * Other
#' * Unknown
#'
#' @return Factor.
#' @export

org_group_to_factor <- function(org_group) {

  groups <- c("Scottish Government (inc. agencies)",
              "Public Health Scotland",
              "Other",
              "Unknown")

  extra <- setdiff(unique(org_group), groups)

  if (any(!org_group %in% groups)) {
    cli::cli_abort(c(
      "x" = paste("{.arg org_group} must only contain following values:",
                  "{.str {groups}}."),
      "i" = "{length(extra)} unexpected value{?s} found: {.str {extra}}."
    ))
  }

  factor(org_group, levels = groups)

}
