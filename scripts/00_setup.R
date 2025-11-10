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


### END OF SCRIPT ###
