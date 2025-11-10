#' Create interactive table of apps
#'
#' @param data Tibble of app data.
#'
#' @return An interactive `gt` table (of class `gt_tbl`).
#' @export

app_table <- function(data) {

  data <- data %>%
    dplyr::select(dplyr::any_of(
      c("url", "org", "status", "updated_time", "total_hours",
        "contact_known", "form_completed_time", "why_shiny")
    ))

  gt::gt(data) %>%
    gt::cols_label(
      dplyr::matches("url") ~
        gt::md("**App**"),
      dplyr::matches("org") ~
        gt::md("**Organisation**"),
      dplyr::matches("status") ~
        gt::md("**Status**"),
      dplyr::matches("updated_time") ~
        gt::md("**App last updated**"),
      dplyr::matches("total_hours") ~
        gt::md("**Total hours used (last 3 months)**"),
      dplyr::matches("contact_known") ~
        gt::md("**Contact known**"),
      dplyr::matches("form_completed_time") ~
        gt::md("**Contact form last completed**"),
      dplyr::matches("why_shiny") ~
        gt::md("**Why Shiny?**")
    ) %>%
    gt::fmt_datetime(
      columns = dplyr::matches("updated_time"),
      date_style = "iso",
      time_style = "iso-short"
    ) %>%
    gt::fmt_date(
      columns = dplyr::matches("form_completed_time"),
      date_style = "iso",
    ) %>%
    gt::sub_missing(
      columns = dplyr::matches("form_completed_time"),
      missing_text = "-"
    ) %>%
    gt::fmt_url(
      columns = dplyr::matches("url"),
      label = function(x) gsub("https://scotland.shinyapps.io/", "", x)
    ) %>%
    gt::cols_width(
      dplyr::matches("why_shiny") ~ gt::pct(70)
    ) %>%
    gt::opt_interactive(use_search = TRUE,
                        use_resizers = FALSE,
                        page_size_default = 25)

}
