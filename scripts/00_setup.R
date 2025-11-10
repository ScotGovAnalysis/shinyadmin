# Name: 00_setup.R
# Description: Load packages and functions required for data processing


# 1 - Load packages ----

library(shinyadmin)
library(dplyr)
library(stringr)
library(here)
library(readr)
library(yaml)
library(cli)
library(purrr)
library(tidyr)
library(lubridate)
library(RtoSQLServer)
library(janitor)
library(readxl)
library(writexl)
library(gt)


# 2 - Set config parameters ----

config <- c(
  read_yaml(here("config.yml")),
  database = "AdministrationShinyapps",
  schema = "supportadmin"
)


# 3 - Read lookup files ----

lookups <- list(
  ms_form_names = read_csv(here("lookups", "ms-form-names.csv"),
                           show_col_types = FALSE),
  orgs  = read_csv(here("lookups", "organisation_lookup.csv"),
                   show_col_types = FALSE)
)


### END OF SCRIPT ###
