library(dplyr)
library(lubridate)

# This does not seem to produce a sensible count and the number changes depending on the interval in a seemingly incorrect way
number_of_connections <- function(app_name, back_months = 3) {
  until_date <- as.Date(Sys.Date())
  from_date <- as.Date(Sys.Date()) - lubridate:::months.numeric(back_months)
  tryCatch(
    {
      initial_df <- rsconnect::showMetrics(appName = app_name, metricSeries = "container_status", metricNames = c("connect_count"), from = from_date, until = until_date)
      colnames(initial_df) <- c("metric", "timestamp", "connect_count")
      # Make connection count numeric
      initial_df$connect_count <- as.numeric(initial_df$connect_count)
      initial_df$timestamp <- as.numeric(initial_df$timestamp)
      initial_df$timestamp <- as.POSIXct(initial_df$timestamp, origin="1970-01-01")
      # Want to take mean connections 8 am to 8 pm, so first calc a mins since midnight column and then use it to filter
      initial_df <- initial_df %>%
        mutate(mins_since_midnight = hour(timestamp) * 60 + minute(timestamp)) %>%
        filter(mins_since_midnight >= 8 * 60 & mins_since_midnight < (20 * 60))
      mean(initial_df$connect_count)
    },
    error = function(e) {
      0
    }
  )
}
