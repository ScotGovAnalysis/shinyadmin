#' Convert grouped organisation data to factor (for sorting)
#'
#' @param org_grouped Character vector of grouped organisations.
#' See Details for accepted values.
#'
#' @details Accepted values in `org_grouped`:
#' * Scottish Government (inc. agencies)
#' * Public Health Scotland
#' * Other
#' * Unknown
#'
#' @return Factor.
#' @export

org_grouped_to_factor <- function(org_grouped) {

  groups <- c("Scottish Government (inc. agencies)",
              "Public Health Scotland",
              "Other",
              "Unknown")

  extra <- setdiff(unique(org_grouped), groups)

  if (any(!org_grouped %in% groups)) {
    cli::cli_abort(c(
      "x" = paste("{.arg org_grouped} must only contain following values:",
                  "{.str {groups}}."),
      "i" = "{length(extra)} unexpected value{?s} found: {.str {extra}}."
    ))
  }

  factor(org_grouped, levels = groups)

}
