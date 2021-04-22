#' @title Convert the coordinates into formatted addresses
#' @description Convert the coordinates into formatted addresses
#' @import data.table
#' @import parallel
#' @import doSNOW
#' @import foreach
#' @import progress
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_replace_all
#' @importFrom stats complete.cases
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @param data The dataset, a data.frame or data.table
#' @param longitude The column having longitude
#' @param latitude The column having latitude
#' @param ncore The specific number of CPU cores used (ncore = 999 by default, which indicates maximum of CPU cores minus 1 )
#' @return  a data.table which adds the formatted address in the original data set.
#' @note The value of "longitude" or "latitude" should be digits in numeric or character format. If not, the function may return empty result for this coordinate automatically.
#' @references Amap. Official documents for developers: Web Service API. https://lbs.amap.com/api/webservice/summary
#' @export geolocation
#' @examples
#' \dontrun{
#' library(amapR)
#' options(amap.key = "xxxxxxxxxxxxxxxx")
#'
#' # Completed data
#' test <- data.frame(n = 1:5000, lng = c(114.4345,104.0837), lat = c(30.51105, 30.63087))
#' results <- geolocation(data = test, longitude = "lng", latitude = "lat")
#'
#' # When the column 'lng' has missing value
#' test <- data.frame(n = 1:5000, lng = c(114.4345,''), lat = c(30.51105, 30.63087))
#' results <- geolocation(data = test, longitude = "lng", latitude = "lat")
#'
#' # When the column 'lng' has special characters
#' test <- data.frame(n = 1:5000, lng = c(114.4345,'?'), lat = c(30.51105, 30.63087))
#' results <- geolocation(data = test, longitude = "lng", latitude = "lat")
#' }
#'
geolocation <- function(data, longitude, latitude, ncore = 999) {
  if (is.null(getOption("amap.key")))
    stop("Please fill your key using 'options(amap.key = 'xxxxxxxxxxxx')' ")
  key <- getOption("amap.key")
  coord_clean <- function(x){
    x <- as.numeric(x)
    x <- round(x, 6)
    return(x)
  }
  if (nrow(data) <= 200) {
    query1 <- function(data, longitude, latitude) {
      df <- as.data.table(data)[, trim_lng := lapply(.SD, coord_clean), .SDcols = longitude
                                ][,trim_lat := lapply(.SD, coord_clean), .SDcols = latitude
                                  ][, miss := is.na(trim_lng) + is.na(trim_lat)
                                    ][miss != 0, trim_lng := 116.480881
                                      ][miss != 0, trim_lat := 39.989410
                                        ][, trim_location := paste(trim_lng, trim_lat, sep = ",")
                                          ][,`:=`(trim_lng = NULL, trim_lat = NULL)]
      results <- data.table()
      pb <- txtProgressBar(max = ceiling(df[,.N]/20), style = 3, char = ":", width = 70)
      for (i in seq(1, df[,.N], by = 20)) {
        try({
          j <- min(i + 19, df[,.N])
          tmp <- df[i:j, ]
          url <- paste0("https://restapi.amap.com/v3/geocode/regeo?", "key=", key,
                        "&batch=true", "&location=", paste0(tmp[,trim_location], collapse = "|"))
          list <- fromJSON(url)
          switch (list$info,
                  "INVALID_USER_KEY" = {
                    message("\nYour key is invalid. Please use a valid key.")
                    break
                  },
                  "DAILY_QUERY_OVER_LIMIT" = {
                    message("\nYour have reached the daily query limit.")
                    break
                  },
                  "ACCESS_TOO_FREQUENT" = {
                    message("\nYour have sent requests too frequent, please try again in 1 min.")
                    break
                  }
          )
          if (identical(list(), list$regeocodes) == TRUE) {
            regeocode <- data.table(formatted_address = NA, n = 1:df[,.N])[,n := NULL]
          } else {
            regeocode <- as.data.table(list$regeocode)[formatted_address %in% c('character(0)'), formatted_address := NA
                                                       ][, .(formatted_address)]
          }
          tmp <- cbind(tmp, regeocode)[miss!=0, formatted_address := NA
                                       ][,`:=`(trim_location = NULL, miss = NULL)]
          results <- rbind(results, tmp)
        })
        setTxtProgressBar(pb, ceiling(i/20))
      }
      fail_rate <- round(sum(is.na(results[,formatted_address]))/results[,.N]*100, 1)
      succ_rate <- round(100 - fail_rate, 1)
      cat(paste0("\nSuccess rate:", succ_rate, "%", " | ", "Failure rate:", fail_rate, "%\n"))
      return(results)
    }
    query1(data, longitude, latitude)
  } else {
    query2 <- function(data, longitude, latitude) {
      df <- as.data.table(data)[, trim_lng := lapply(.SD, coord_clean), .SDcols = longitude
                                ][,trim_lat := lapply(.SD, coord_clean), .SDcols = latitude
                                  ][, miss := is.na(trim_lng) + is.na(trim_lat)
                                    ][miss != 0, trim_lng := 116.480881
                                      ][miss != 0, trim_lat := 39.989410
                                        ][, trim_location := paste(trim_lng, trim_lat, sep = ",")
                                          ][,`:=`(trim_lng = NULL, trim_lat = NULL)]
      url <- paste0("https://restapi.amap.com/v3/geocode/regeo?", "key=", key,
                    "&batch=true", "&location=", paste0(df[,trim_location], collapse = "|"))
      list <- fromJSON(url)
      switch (list$info,
              "INVALID_USER_KEY" = {
                stop("\nYour key is invalid. Please use a valid key.")
              },
              "DAILY_QUERY_OVER_LIMIT" = {
                stop("\nYour have reached the daily query limit.")
              },
              "ACCESS_TOO_FREQUENT" = {
                stop("\nYour have sent requests too frequent, please try again in 1 min.")
              }
      )
      if (identical(list(), list$regeocodes) == TRUE) {
        regeocode <- data.table(formatted_address = NA, n = 1:df[,.N])[,n := NULL]
      } else {
        regeocode <- as.data.table(list$regeocode)[formatted_address %in% c('character(0)'), formatted_address:=NA
                                                   ][, .(formatted_address)]
      }
      dat <- cbind(df, regeocode)[miss!=0, formatted_address := NA
                                  ][,`:=`(trim_location = NULL, miss = NULL)]
      return(dat)
    }
    spldata <- split(data, f = ceiling(seq(nrow(data))/20))
    pb <- txtProgressBar(max = length(spldata), style = 3, char = ":", width = 70)
    progress <- function(n) setTxtProgressBar(pb, n)
    opts <- list(progress = progress)
    cores <- min((detectCores() - 1), ncore)
    cl <- makeCluster(cores)
    registerDoSNOW(cl)
    boot <- foreach(i = seq_len(length(spldata)), .options.snow = opts)
    myfunc <- function(i) { query2(spldata[[i]], longitude, latitude) }
    result <- `%dopar%`(boot, myfunc(i))
    results <- do.call('rbind', result)
    stopCluster(cl)
    fail_rate <- round(sum(is.na(results[,formatted_address]))/results[,.N]*100, 1)
    succ_rate <- round(100 - fail_rate, 1)
    cat(paste0("\nSuccess rate:", succ_rate, "%", " | ", "Failure rate:", fail_rate, "%\n"))
    return(results)
  }
}
