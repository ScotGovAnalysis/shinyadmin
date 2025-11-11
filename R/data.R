#' Microsoft Form Names
#'
#' A lookup dataset for renaming columns in the Microsoft Forms contact dataset.
#'
#' @format
#' A tibble with 2 columns:
#' \describe{
#'   \item{new}{Clean snakecase names to use in the analysis dataset}
#'   \item{old}{Exact question wording in the MS form}
#' }

"ms_form_names"


#' Organisations
#'
#' A lookup dataset for organisations with deployed apps.
#'
#' @format
#' A tibble with 4 columns:
#' \describe{
#'   \item{org_acronym}{Organisation acronym used as prefix in app name}
#'   \item{org_name}{Organisation name}
#'   \item{org_group}{Organisation group (groups Scottish Government with its
#'   agencies)}
#'   \item{ms_form_accepted}{Logical. Is the organisation a currently accepted
#'   value in the Microsoft Form?}
#' }

"orgs"
