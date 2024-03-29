#' @title Convert addresses into coordinates
#' @description Convert addresses into coordinates
#' @import data.table
#' @import parallel
#' @import doSNOW
#' @import foreach
#' @import progress
#' @import crayon
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_replace_all
#' @importFrom stats complete.cases
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @param data The dataset, a data.frame or data.table.
#' @param address The column name of address
#' @param city Specify the city to query. This argument supports the city name in Chinese, the city name in pinyin, the administrative code of city or the city code defined by Amap.
#' By default, this argument is empty. For more information, see the Amap official documents at https://lbs.amap.com/api/webservice/guide/api/georegeo.
#' @param ncore The specific number of CPU cores used (ncore = 999 by default, which indicates the maximum of CPU cores minus 1 were used in parallel computing if your CPU is less than 999 cores)
#' @param nquery The number of query in each batch (nquery = 10 by default). This argument is used to avoid the http 413 error when the request url is too long.
#' @return a data.table which adds the formatted address, longitude and latitude in the original data set.
#' @note (1) According to the official document of AMap Web Service API, the address in the data set should be in Chinese format.
#' If a address is in English or includes special characters (i.e., ?, -, >, _, etc.), the function may return empty result for this address automatically.
#' (2) Task may fail when the network connection between you and Amap API is unstable. To avoid loop break in this function, the result for that task will not be returned. Therefore, the final results returned may be less than the original data.
#' If you want to check where the task failed, I suggest adding an ID column to the original data and comparing the IDs between the final results returned and original data.
#' @references Amap. Official documents for developers: Web Service API. https://lbs.amap.com/api/webservice/summary
#' @export geocoord
#' @examples
#' \dontrun{
#' library(amapR)
#' options(amap.key = "xxxxxxxxxxxx")
#'
#' # Note: The "address" is the column having Chinese addresses, and the data set named "test"
#' # should be a data.frame or a data.table.
#' results <- geocoord(data = test, address = "address")
#'
#' # Set the specific number of CPU cores used and the number of query in each batch
#' results <- geocoord(data = test, address = "address", ncore = 4, nquery = 5)
#'
#' # Specify the city to query
#' results <- geocoord(data = test, address = "address", city = "chengdu")
#' }
#'
geocoord <- function(data, address, city = "", ncore = 999, nquery = 10) {
  options(digits=9)
  key <- getOption("amap.key")
  if (is.null(getOption("amap.key"))) {
    stop("Please fill your key using 'options(amap.key = 'xxxxxxxxxxxx')' ")
  }
  if (nquery > 10) {
    stop("The maximum of query per batch is 10. Please reset the number of nquery.")
  }
  stringreplace <- function(x) {
      x <- str_replace_all(x, "[^[:alnum:]]", "_")
      x <- str_replace_all(x, "[a-z]", "_")
      x <- str_replace_all(x, "A-Z", "_")
      x[is.na(x) == T] <- "_"
      x[x == ""] <- "_"
    return(x)
  }
  if (nrow(data) <= 200) {
    query1 <- function(data, address, city, nquery) {
      df <- as.data.table(data)
      dat <- data.table()
      pb <- txtProgressBar(max = ceiling(df[, .N] / nquery), style = 3, char = ":", width = 70)
      for (i in seq(1, df[, .N], by = nquery)) {
        j <- min(i + (nquery - 1), df[, .N])
        tmp <- df[i:j, ][, trim_addr := lapply(.SD, stringreplace), .SDcols = address]
        url <- paste0("https://restapi.amap.com/v3/geocode/geo?", "key=", key,
                      "&batch=true", "&address=", paste0(tmp[, trim_addr], collapse = "|"), "&city=", city)
        list <- fromJSON(url)
        for (z in 1:10) {
           if (length(list) != 5) { list <- fromJSON(url) }
         }
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
        if (identical(list(), list$geocodes) == TRUE) {
          geocode <- data.table(location = NA, formatted_address = NA, n = 1:df[, .N])[, n := NULL]
        } else {
          geocode <- as.data.table(list$geocodes)[, .(location, formatted_address)
                                                  ][location %in% c("character(0)"), location := NA
                                                    ][formatted_address %in% c("character(0)"), formatted_address := NA]
        }
        tmp <- cbind(tmp, geocode)[, trim_addr := NULL]
        dat <- rbind(dat, tmp)
        utils::setTxtProgressBar(pb, ceiling(i / nquery))
      }
      results <- dat[, c("longitude", "latitude") := tstrsplit(location, ",", fixed = TRUE)
                     ][, longitude := as.numeric(longitude)
                       ][, latitude := as.numeric(latitude)
                         ][, location := NULL]
      n_missed <- nrow(data) - nrow(results)
      succ_rate <- round(sum(complete.cases(results[, longitude])) / nrow(data) * 100, 1)
      fail_rate <- round(100 - succ_rate, 1)
      cat("\nUnfinished case(s): " %+% underline(n_missed) %+% "\nSuccess: " %+% green(succ_rate) %+% green("%") %+% " | " %+%  "Failure: " %+% red(fail_rate) %+% red("%\n"))
      return(results)
    }
    query1(data, address, city, nquery)
  } else {
    query2 <- function(data, address, city, nquery) {
      df <- as.data.table(data)
      tmp <- df[, trim_addr := lapply(.SD, stringreplace), .SDcols = address]
      url <- paste0("https://restapi.amap.com/v3/geocode/geo?", "key=",
                    key, "&batch=true", "&address=", paste0(tmp[, trim_addr], collapse = "|"), "&city=", city)
      list <- fromJSON(url)
      for (z in 1:10) {
           if (length(list) != 5) { list <- fromJSON(url) }
        }
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
      if (identical(list(), list$geocodes) == TRUE) {
        geocode <- data.table(location = NA, formatted_address = NA, n = 1:df[, .N])[, n := NULL]
      } else {
        geocode <- as.data.table(list$geocodes)[, .(location, formatted_address)
                                                ][location %in% c("character(0)"), location := NA
                                                  ][formatted_address %in% c("character(0)"), formatted_address := NA]
      }
      dat <- cbind(tmp, geocode)[, trim_addr := NULL]
      return(dat)
    }
    spldata <- split(data, f = ceiling(seq(nrow(data)) / nquery))
    pb <- txtProgressBar(max = length(spldata), style = 3, char = ":", width = 70)
    progress <- function(n) setTxtProgressBar(pb, n)
    opts <- list(progress = progress)
    cores <- min((detectCores() - 1), ncore)
    cl <- makeCluster(cores)
    registerDoSNOW(cl)
    boot <- foreach(i = seq_len(length(spldata)), .options.snow = opts, .errorhandling = "remove")
    myfunc <- function(i) {
      query2(spldata[[i]], address, city, nquery)
    }
    result <- `%dopar%`(boot, myfunc(i))
    results <- do.call('rbind', result)[, c("longitude", "latitude") := tstrsplit(location, ",", fixed = TRUE)
                                        ][, longitude := as.numeric(longitude)
                                          ][, latitude := as.numeric(latitude)
                                            ][, location := NULL]
    stopCluster(cl)
    n_missed <- nrow(data) - nrow(results)
    succ_rate <- round(sum(complete.cases(results[, longitude])) / nrow(data) * 100, 1)
    fail_rate <- round(100 - succ_rate, 1)
    cat("\nUnfinished case(s): " %+% underline(n_missed) %+% "\nSuccess: " %+% green(succ_rate) %+% green("%") %+% " | " %+%  "Failure: " %+% red(fail_rate) %+% red("%\n"))
    return(results)
  }
}
