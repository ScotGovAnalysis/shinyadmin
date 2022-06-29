#This does not seem to produce a sensible count and the number changes depending on the interval in a seemingly incorrect way
number_of_connections <- function(app_name, back_months = 3) {
  until_date <- as.Date(Sys.Date())
  from_date <- as.Date(Sys.Date()) - lubridate:::months.numeric(back_months)
  tryCatch(
    {
      initial_df <- rsconnect::showMetrics(appName=app_name, metricSeries = "container_status", metricNames = c("connect_count"), from = from_date, until=until_date, interval="1d")
      colnames(initial_df) <- c("metric", "timestampe", "connect_count")
      initial_df$connect_count <- as.numeric(initial_df$connect_count)
      mean(initial_df$connect_count)
    },
    error = function(e) {
      0
    }
  )
}