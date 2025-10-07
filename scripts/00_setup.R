# Name: 00_setup.R
# Description: Load packages and functions required for data processing


# 1 - Load packages ----

library(rsconnect)
library(dplyr)
library(lubridate)
library(stringr)
library(here)
library(readr)
library(here)
library(yaml)
library(purrr)
library(tidyr)
library(lubridate)
library(RtoSQLServer)


# 2 - Load functions ----

walk(
  list.files(here("R"), pattern = "*.R$", full.names = TRUE),
  source
)


# 3 - Set config parameters ----

config <- c(
  read_yaml(here("config.yml")),
  database = "AdministrationShinyapps",
  schema = "supportadmin"
)


### END OF SCRIPT ###