source("R/hours_used.R")
source("R/app_visibility.R")

# get all applications to dataframe
# Need to make sure connection is set in R Studio first, see README.md
df_applications <- rsconnect::applications()

# add hours used to dataframe using custom function
df_applications <- dplyr::mutate(df_applications, hours_used = sapply(name, hours_used, back_months=3))

# add the visbility of the app whether public or private using custom function
df_applications <- dplyr::mutate(df_applications, visibility = sapply(name, app_visibility))

# select columns to output
output_columns <- c("name", "url", "visibility", "created_time", "hours_used") 

df_applications <- dplyr::select(df_applications, all_of(output_columns))

# Sort desc by usage
df_applications <- dplyr::arrange(df_applications, dplyr::desc(hours_used)) 

# Create output fp
output_full_path <- paste0("outputs/shiny_app_usage_", Sys.Date(), ".csv")

# Write to csv
readr::write_csv(df_applications, output_full_path)
