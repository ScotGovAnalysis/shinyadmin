orgs <-
  tibble::tribble(
    ~ org_acronym, ~ org_name, ~ org_group, ~ ms_form_accepted,
    "sg", "Scottish Government", "Scottish Government (inc. agencies)", TRUE,
    "nrs", "National Records of Scotland", "Scottish Government (inc. agencies)", TRUE,
    "phs", "Public Health Scotland", "Public Health Scotland", TRUE,
    "scotpho", "Public Health Scotland", "Public Health Scotland", FALSE,
    "isd", "Public Health Scotland", "Public Health Scotland", FALSE,
    "nhs", "Public Health Scotland", "Public Health Scotland", FALSE,
    "is", "Improvement Service", "Other", TRUE,
    "snh", "NatureScot", "Other", TRUE,
    "ts", "Transport Scotland", "Scottish Government (inc. agencies)", TRUE,
    "fwc", "Fair Work Convention", "Scottish Government (inc. agencies)", TRUE,
    "ps", "Police Scotland", "Other", TRUE
  )

usethis::use_data(orgs, overwrite = TRUE)
