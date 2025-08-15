# Name: 03_output.R
# Description: Save app data to formatted Excel file


# 0 - Load packages and functions ----

library(here)
library(readr)
library(dplyr)
library(janitor)
library(forcats)
library(purrr)
library(writexl)
library(tidyr)

source(here("R", "get_latest_output.R"))


# 1 - Read app data ----

apps <-
  
  read_rds(get_latest_output("app-data")) %>%
  
  # Group SG agencies as one organisation
  mutate(
    org_grouped = case_when(
      sg_agency ~ "Scottish Government (inc. agencies)",
      org == "Public Health Scotland" ~ org,
      !is.na(org) ~ "Other",
      is.na(org) ~ "Unknown"
    ),
    org_grouped = factor(org_grouped, 
                         levels = c("Scottish Government (inc. agencies)",
                                    "Public Health Scotland",
                                    "Other",
                                    "Unknown")),
    org = replace_na(org, "Unknown")
  ) %>%
  select(-sg_agency)


# 2 - Summary by organisation ----

summary <-
  apps %>%
  group_by(org = org_grouped) %>%
  summarise(n_apps = n(),
            n_contact_known = sum(contact_known),
            .groups = "drop") %>%
  adorn_totals()


# 3 - List of data to save to Excel ----

out <- 
  c(
    list(Summary = summary),
    split(apps, apps$org_grouped)
  ) %>%
  set_names(
    \(x) ifelse(x == "Scottish Government (inc. agencies)",
                "SG (inc. agencies)",
                x)
  ) %>%
  imap(
    \(x, idx) if (idx == "Summary") {
      x
    } else {
      x %>% 
        select(-any_of(c("contact_known", "org_grouped"))) %>%
        arrange(org != "Scottish Government", org, name) %>%
        relocate(org, .before = 0)
    }
  )


# 4 - Save excel output ----

write_xlsx(
  out,
  here("outputs", paste0(Sys.Date(), "_shiny-apps.xlsx")),
  format_headers = FALSE
)


### END OF SCRIPT ###