#' @title Transform the coordinates from other coordinate systems to Amap system
#' @description This function supports to transform the coordinates from three other coordinate systems (including baidu, GPS and mapbar) to Amap system
#' @import data.table
#' @import parallel
#' @import doSNOW
#' @import foreach
#' @import progress
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_replace_all
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @param data The dataset, a data.frame or data.table
#' @param longitude The column having longitude
#' @param latitude The column having latitude
#' @param coordsys The coordinate system of your original location data, such as "gps", "baidu", "mapbar" and "autonavi" (coordsys = "autonavi" by default)
#' @param ncore The specific number of CPU cores used (ncore = 999 by default, which indicates the maximum of CPU cores minus 1 were used in parallel computing if your CPU is less than 999 cores)
#' @return a data.table which adds the transformed longitude and latitude using Amap System in the original data set
#' @note The value of "longitude" or "latitude" should be digits in numeric or character format. If not, the function may return empty result for this coordinate automatically
#' @references Amap. Official documents for developers: Web Service API. https://lbs.amap.com/api/webservice/summary
#' @export transcoord
#' @examples
#' \dontrun{
#' library(amapR)
#' options(amap.key = "xxxxxxxxxxxxxxxx")
#'
#' # Completed data
#' test <- data.frame(n = 1:500, lng = c(114.4345,104.0837), lat = c(30.51105, 30.63087))
#' results <- transcoord(data = test, longitude = "lng", latitude = "lat", coordsys = "baidu")
#' }
transcoord <- function(data, longitude, latitude, coordsys = "autonavi", ncore = 999) {
  if (is.null(getOption("amap.key")))
    stop("Please fill your key using 'options(amap.key = 'xxxxxxxxxxxx')' ")
  key <- getOption("amap.key")
  coord_clean <- function(x){
    x <- as.numeric(x)
    x <- round(x, 6)
    if (is.numeric(x) == F){
      x <- str_replace_all(x, "[^[:alnum:]]", "")
      x <- str_replace_all(x, "[a-z]", "")
      x <- str_replace_all(x, "A-Z", "")
    }
    return(x)
  }
  if (nrow(data) <= 200) {
    query1 <- function(data, longitude, latitude, coordsys) {
      df <- as.data.table(data)[, trim_lng := lapply(.SD, coord_clean), .SDcols = longitude
                                ][,trim_lat := lapply(.SD, coord_clean), .SDcols = latitude
                                  ][, miss_lng := is.na(trim_lng)
                                    ][, miss_lat := is.na(trim_lat)
                                      ][is.na(trim_lng) == T, trim_lng := 116.480881
                                        ][is.na(trim_lat) == T, trim_lat := 39.989410
                                          ][, trim_location := paste(trim_lng, trim_lat, sep = ",")
                                            ][,`:=`(trim_lng = NULL, trim_lat= NULL)]
      results <- data.table()
      pb <- txtProgressBar(max = ceiling(df[,.N]/40), style = 3, char = ":", width = 70)
      for (i in seq(1, df[,.N], by = 40)) {
        try({
          j <- min(i + 39, df[,.N])
          tmp <- df[i:j, ]
          url <- paste0("https://restapi.amap.com/v3/assistant/coordinate/convert?", "key=", key, "&coordsys=", coordsys, "&locations=", paste0(tmp[,trim_location], collapse = "|"))
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
          if (identical(list(), list$locations) == TRUE) {
            new_coord <- data.table(lng_amap = NA, lat_amap = NA, n = 1:df[,.N])[,n:=NULL]
          } else {
            new_coord <- as.matrix(tstrsplit(list$locations, ";", fixed = TRUE))
            colnames(new_coord) <- "location"
            new_coord <- as.data.table(new_coord)[, c("lng_amap", "lat_amap") := tstrsplit(location, ",", fixed = TRUE)
                                                  ][,lng_amap := lapply(.SD, coord_clean), .SDcols = "lng_amap"
                                                    ][,lat_amap := lapply(.SD, coord_clean), .SDcols = "lat_amap"]
          }
          tmp <- cbind(tmp, new_coord)[miss_lng == T, lng_amap := NA
                                       ][miss_lat == T, lat_amap := NA]
          results <- rbind(results, tmp)
        })
        setTxtProgressBar(pb, ceiling(i/40))
      }
      results <- results[, `:=`(miss_lng = NULL, miss_lat = NULL, trim_location = NULL, location = NULL)]
      succ_rate <- round(results[is.na(lng_amap) == F & is.na(lat_amap) == F,.N]/results[,.N]*100, 1)
      fail_rate <- round(100 - succ_rate, 1)
      cat(paste0("\nSuccess rate:", succ_rate, "%", " | ", "Failure rate:", fail_rate, "%\n"))
      return(results)
    }
    query1(data, longitude, latitude, coordsys)
  } else {
    query2 <- function(data, longitude, latitude, coordsys) {
      df <- as.data.table(data)[, trim_lng := lapply(.SD, coord_clean), .SDcols = longitude
                                ][,trim_lat := lapply(.SD, coord_clean), .SDcols = latitude
                                  ][, miss_lng := is.na(trim_lng)
                                    ][, miss_lat := is.na(trim_lat)
                                      ][is.na(trim_lng) == T, trim_lng := 116.480881
                                        ][is.na(trim_lat) == T, trim_lat := 39.989410
                                          ][, trim_location := paste(trim_lng, trim_lat, sep = ",")
                                            ][,`:=`(trim_lng = NULL, trim_lat= NULL)]
      url <- paste0("https://restapi.amap.com/v3/assistant/coordinate/convert?", "key=", key, "&coordsys=", coordsys, "&locations=", paste0(df[,trim_location], collapse = "|"))
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
      if (identical(list(), list$locations) == TRUE) {
        new_coord <- data.table(lng_amap = NA, lat_amap = NA, n = 1:df[,.N])[,n:=NULL]
      } else {
        new_coord <- as.matrix(tstrsplit(list$locations, ";", fixed = TRUE))
        colnames(new_coord) <- "location"
        new_coord <- as.data.table(new_coord)[, c("lng_amap", "lat_amap") := tstrsplit(location, ",", fixed = TRUE)
                                              ][,lng_amap := lapply(.SD, coord_clean), .SDcols = "lng_amap"
                                                ][,lat_amap := lapply(.SD, coord_clean), .SDcols = "lat_amap"]
      }
      dat <- cbind(df, new_coord)[, `:=`(miss_lng = NULL, miss_lat = NULL, trim_location = NULL, location = NULL)]
      return(dat)
    }
    spldata <- split(data, f = ceiling(seq(nrow(data))/40))
    pb <- txtProgressBar(max = length(spldata), style = 3, char = ":", width = 70)
    progress <- function(n) setTxtProgressBar(pb, n)
    opts <- list(progress = progress)
    cores <- min((detectCores() - 1), ncore)
    cl <- makeCluster(cores)
    registerDoSNOW(cl)
    boot <- foreach(i = seq_len(length(spldata)), .options.snow = opts)
    myfunc <- function(i) { query2(spldata[[i]], longitude, latitude, coordsys) }
    result <- `%dopar%`(boot, myfunc(i))
    results <- do.call('rbind', result)
    stopCluster(cl)
    succ_rate <- round(results[is.na(lng_amap) == F & is.na(lat_amap) == F,.N]/results[,.N]*100, 1)
    fail_rate <- round(100 - succ_rate, 1)
    cat(paste0("\nSuccess rate:", succ_rate, "%", " | ", "Failure rate:", fail_rate, "%\n"))
    return(results)
  }
}
