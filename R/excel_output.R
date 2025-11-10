#' Format app data into excel output
#'
#' @param analysis_table Data frame of app data.
#' @param org_group Character. Either "all" to include all organisations in the
#'  output, or an organisation group that appears in
#'  `analysis_table$org_grouped`.
#'
#' @return Named list of data frames, that when using `writexl::write_xlsx`,
#'  will be sheets in an Excel file.
#' @export

excel_output <- function(analysis_table, org_group = "all") {

  if (org_group != "all" & !org_group %in% analysis_table$org_group) {
    cli::cli_abort(c(
      "x" = paste("{.arg org_group} must be {.str all}",
                  "or a valid organisation group."),
      "i" = paste("There are no apps for {.str {org_group}} in",
                  "{.arg analysis_table$org_grouped}.")
    ))
  }

  apps <-

    analysis_table %>%

    # Recode to character - otherwise time added by Excel
    dplyr::mutate(record_date = as.character(.data$record_date)) %>%

    # Set order for org_grouped
    dplyr::mutate(org_grouped = org_grouped_to_factor(.data$org_grouped)) %>%
    dplyr::select(-"sg_agency") %>%

    # Filter for org_grouped if provided
    dplyr::filter(
      if (org_group != "all") .data$org_grouped == org_group else TRUE
    )


  # Summary by organisation ----

  if (org_group == "all") {

    summary <-
      apps %>%
      dplyr::select(-"org") %>%
      dplyr::rename(org = .data$org_grouped) %>%
      dplyr::group_by(.data$org) %>%
      dplyr::summarise(n_apps_active   = sum(.data$status == "active"),
                       n_apps_inactive = sum(.data$status != "active"),
                       n_contact_known = sum(!is.na(.data$form_completed_time)),
                       .groups = "drop") %>%
      janitor::adorn_totals()

  }

  # List of data to save to Excel ----

  out <-
    c(
      if (org_group == "all") list(Summary = summary),
      split(apps, apps$org_grouped)
    ) %>%
    purrr::discard(\(x) nrow(x) == 0) %>%
    purrr::set_names(
      \(x) ifelse(x == "Scottish Government (inc. agencies)",
                  "SG (inc. agencies)",
                  x)
    ) %>%
    purrr::imap(
      \(x, idx) if (idx == "Summary") {
        x
      } else if (idx == "Other") {
        x %>%
          dplyr::select(-dplyr::any_of(c("contact_known", "org_grouped"))) %>%
          dplyr::arrange(
            .data$org != "Scottish Government", .data$org, .data$name
          ) %>%
          dplyr::relocate("org", "org_other", .before = 0)
      } else {
        x %>%
          dplyr::select(
            -dplyr::any_of(c("contact_known", "org_grouped", "org_other"))
          ) %>%
          dplyr::arrange(
            .data$org != "Scottish Government", .data$org, .data$name
          ) %>%
          dplyr::relocate("org", .before = 0)
      }
    )

  out

}
