#' @title Convert addresses into coordinates
#' @description Convert addresses into coordinates
#' @import data.table
#' @import parallel
#' @import doSNOW
#' @import foreach
#' @import progress
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_replace_all
#' @importFrom stats complete.cases
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @param data The dataset, a dataframe or data.table
#' @param address The column name of address
#' @param ncore the number of CPU cores used
#' @return data.table
#' @export geocoord
#' @examples
#' \dontrun{
#' library(amap)
#' options(amap.key = "xxxxxxxxxxxx")
#'
#' # address is the column having Chinese addresses,
#' # and the data set named test should be a data.frame or a data.table.
#' result <- geocoord(data = test, address = "address")
#'
#' # limit the number of CPU cores used in geocoord
#' result <- geocoord(data = test, address = "address", ncore = 4)
#' }

geocoord <- function(data, address, ncore = 1000000000) {
  if (is.null(getOption("amap.key"))) stop("Please fill your key using 'options(amap.key = 'xxxxxxxxxxxx')' ")
  key <- getOption("amap.key")
  stringreplace=function(x){
    x <- str_replace_all(x, "[^[:alnum:]]", "_")
    x <- str_replace_all(x, "[a-z]", "_")
    x <- str_replace_all(x, "A-Z", "_")
    return(x)
  }
  if (nrow(data) <= 200) {
    query1 <- function(data, address) {
      df <- as.data.table(data)
      dat <- data.table()
      pb <- txtProgressBar(max = ceiling(df[,.N]/10), style = 3, char = ":", width = 70)
      for (i in seq(1, df[,.N], by = 10)) {
        j <- min(i + 9, df[,.N])
        tmp <- df[i:j, ][, trim_addr :=lapply(.SD, stringreplace), .SDcols = address]
        url <- paste0("https://restapi.amap.com/v3/geocode/geo?", "key=", key, "&batch=true", "&address=", paste0(tmp[,trim_addr], collapse = "|"))
        list <- fromJSON(url)
        if (identical(list(), list$geocodes) == TRUE) {
          geocode <- data.table(location = NA, formatted_address = NA, n = 1:df[,.N])[,n:=NULL]
        } else {
          geocode <- as.data.table(list$geocodes)[,.(location, formatted_address)][location %in% c('character(0)'), location:=NA][formatted_address %in% c('character(0)'), formatted_address:=NA]
        }
        tmp <- cbind(tmp, geocode)[,trim_addr:= NULL]
        dat <- rbind(dat, tmp)
        utils::setTxtProgressBar(pb, ceiling(i/10))
      }
      results <- dat[, c("longitude", "latitude") := tstrsplit(location, ",", fixed = TRUE )][, longitude := as.numeric(longitude)][, latitude := as.numeric(latitude)][, location:=NULL]
      succ_rate <- round(sum(complete.cases(results[,longitude]))/results[,.N]*100, 1)
      fail_rate <- round(100 - succ_rate, 1)
      cat(paste0("\nSuccess rate:", succ_rate, "%", " | ", "Failure rate:", fail_rate, "%\n"))
      return(results)
    }
    query1(data, address)
  } else {
    query2 <- function(data, address) {
      df <- as.data.table(data)
      tmp <- df[, trim_addr :=lapply(.SD, stringreplace), .SDcols = address]
      url <- paste0("https://restapi.amap.com/v3/geocode/geo?", "key=", key, "&batch=true", "&address=", paste0(tmp[,trim_addr], collapse = "|"))
      list <- fromJSON(url)
      if (identical(list(), list$geocodes) == TRUE) {
        geocode <- data.table(location = NA, formatted_address = NA, n = 1:df[,.N])[,n:=NULL]
      } else {
        geocode <- as.data.table(list$geocodes)[,.(location, formatted_address)][location %in% c('character(0)'), location:=NA][formatted_address %in% c('character(0)'), formatted_address:=NA]
      }
      dat <- cbind(tmp, geocode)[,trim_addr:= NULL]
      return(dat)
    }
    spldata <- split(data, f = ceiling(seq(nrow(data))/10))
    pb <- txtProgressBar(max = length(spldata), style = 3, char = ":", width = 70)
    progress <- function(n) setTxtProgressBar(pb, n)
    opts <- list(progress = progress)
    cores <- min((detectCores() - 1), ncore)
    cl <- makeCluster(cores)
    registerDoSNOW(cl)
    boot <- foreach(i = seq_len(length(spldata)), .options.snow = opts)
    myfunc <- function(i) { query2(spldata[[i]], address) }
    result <- `%dopar%`(boot, myfunc(i))
    results <- do.call('rbind', result)[, c("longitude", "latitude") := data.table::tstrsplit(location, ",", fixed = TRUE )][, longitude := as.numeric(longitude)][, latitude := as.numeric(latitude)][, location := NULL]
    succ_rate <- round(sum(complete.cases(results[,longitude]))/results[,.N]*100, 1)
    fail_rate <- round(100 - succ_rate, 1)
    cat(paste0("\nSuccess rate:", succ_rate, "%", " | ", "Failure rate:", fail_rate, "%\n"))
    return(results)
    stopCluster(cl)
  }
}
