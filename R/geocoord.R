#' @title Converting the addresses to coordinates
#' @description Converting the address to coordinates
#' @import jsonlite
#' @import progress
#' @import dplyr
#' @import parallel
#' @import pbapply
#' @param address The address
#' @param n The number of batch query, n = 10 by default
#' @return a data.frame
#' @export geocoord
#' @examples
#' library(amap)
#' options(amap.key = "xxxxxxxxxxxxxxxxxx")
#' geocoord("your address in Chinese format")
geocoord <- function(address, n = 10) {
  if (length(address) <= 600) {
    query1 <- function(address, n = 10) {
      if (is.null(getOption("amap.key"))) stop("Please fill your key using 'options(amap.key = 'XXXXXXXXXXXXX')' ")
      key <- getOption("amap.key")
      df <- as.data.frame(address)
      dat <- slice(df, 0)
      dat$coordinate <- NULL
      pb <- progress_bar$new(format = "Processing: [:bar] :percent eta: :eta", total = length(seq(1, nrow(df), by = n)))
      pb$tick(0)
      for (i in seq(1, nrow(df), by = n)) {
        pb$tick(1)
        try({
          j <- i + n - 1
          tmp <- slice(df, i:j)
          url <- paste0("https://restapi.amap.com/v3/geocode/geo?",
                        "key=", key,
                        "&batch=true",
                        "&address=", paste0(pull(tmp, address), collapse = "|"))
          list <- fromJSON(url)
          geocodes <- as.data.frame(list$geocodes)
          coord <- select(geocodes, coordinate = location)
          tmp <- bind_cols(tmp, coord)
          tmp$coordinate <- as.character(tmp$coordinate)
          dat <- bind_rows(dat, tmp)
        })
      }
      finaldat <- tidyr::separate(dat, "coordinate", into = c("longitude", "latitude"), sep = ",")
      finaldat$longitude <- as.numeric(finaldat$longitude)
      finaldat$latitude <- as.numeric(finaldat$latitude)
      return(finaldat)
    }
    query1(address, n)
  } else {
    if (is.null(getOption("amap.key"))) stop("Please fill your key using 'options(amap.key = 'XXXXXXXXXXXXX')' ")
    key <- getOption("amap.key")
    query2 <- function(address, n = 10) {
      df <- as.data.frame(address)
      dat <- slice(df, 0)
      dat$coordinate <- NULL
      for (i in seq(1, nrow(df), by = n)) {
        try({
          j <- i + n - 1
          tmp <- slice(df, i:j)
          url <- paste0("https://restapi.amap.com/v3/geocode/geo?",
                        "key=", key,
                        "&batch=true",
                        "&address=", paste0(pull(tmp, address), collapse = "|"))
          geocodes <- as.data.frame(list$geocodes)
          coord <- select(geocodes, coordinate = location)
          tmp <- bind_cols(tmp, coord)
          tmp$coordinate <- as.character(tmp$coordinate)
          dat <- bind_rows(dat, tmp)
        })
      }
      finaldat <- tidyr::separate(dat, "coordinate", into = c("longitude", "latitude"), sep = ",")
      finaldat$longitude <- as.numeric(finaldat$longitude)
      finaldat$latitude <- as.numeric(finaldat$latitude)
      return(finaldat)
    }
    spldata <- split(address, f = ceiling(seq(length(address)) / n))
    cores <- detectCores()
    cl <- makeCluster(cores)
    result <- pblapply(
      cl = cl, X = seq_len(length(spldata)),
      FUN = function(i) {
        result <- query2(unlist(spldata[[i]]))
        return(result)
      }
    )
    finaldat <- bind_rows(result)
    return(finaldat)
    stopCluster(cl)
  }
}
