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

  trim_address <- function(x){
    x <- gsub("#", "", x)
    x <- gsub(">", "", x)
    x <- gsub("\\s", "", x)
    return(x)
  }

  vars_list <-  c('location','formatted_address', 'country', 'province', 'city',
                  'district', 'township', 'street', 'number', 'citycode', 'adcode')

  if (length(address) <= 500) {
    query1 <- function(address, n = 10) {
      if (is.null(getOption("amap.key"))) stop("Please fill your key using 'options(amap.key = 'XXXXXXXXXXXXX')' ")
      key <- getOption("amap.key")
      df <- as.data.frame(address)
      dat <- slice(df, 0)
      dat <- data.frame(
        address = NULL,
        location = NULL,
        formatted_address = NULL,
        country = NULL,
        province = NULL,
        city = NULL,
        district = NULL,
        township = NULL,
        street = NULL,
        number = NULL,
        citycode = NULL,
        adcode = NULL
      )
      pb <- progress_bar$new(format = "Processing: [:bar] :percent eta: :eta", total = length(seq(1, nrow(df), by = n)))
      pb$tick(0)
      for (i in seq(1, nrow(df), by = n)) {
        pb$tick(1)
        try({
          j <- i + n - 1
          tmp <- slice(df, i:j)
          url <- paste0("https://restapi.amap.com/v3/geocode/geo?",
                        "key=", key, "&batch=true",
                        "&address=", trim_address(paste0(pull(tmp, address), collapse = "|"))
          )
          list <- fromJSON(url)
          geocode <- list$geocodes %>% select(vars_list)
          # replace character(0) and list() with NA
          for (i in vars_list) {
            geocode[[i]] <- lapply(geocode[[i]],function(x) {
              if(identical(x, character(0))) NA_character_ else x
            })
            geocode[[i]] <- lapply(geocode[[i]],function(x) {
              if(identical(x, list())) NA_character_ else x
            })
          }
          tmp <- bind_cols(tmp, geocode)
          tmp$location <- as.character(tmp$location)
          dat <- bind_rows(dat, tmp)
        })
      }
      finaldat <- tidyr::separate(dat, "location", into = c("longitude", "latitude"), sep = ",")
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
      dat <- data.frame(
        address = NULL,
        location = NULL,
        formatted_address = NULL,
        country = NULL,
        province = NULL,
        city = NULL,
        district = NULL,
        township = NULL,
        street = NULL,
        number = NULL,
        citycode = NULL,
        adcode = NULL
      )
      for (i in seq(1, nrow(df), by = n)) {
        try({
          j <- i + n - 1
          tmp <- slice(df, i:j)
          url <- paste0("https://restapi.amap.com/v3/geocode/geo?",
                        "key=", key, "&batch=true",
                        "&address=", trim_address(paste0(pull(tmp, address), collapse = "|"))
          )
          list <- fromJSON(url)
          geocode <- list$geocodes %>% select(vars_list)
          # replace character(0) and list() with NA
          for (i in vars_list) {
            geocode[[i]] <- lapply(geocode[[i]],function(x) {
              if(identical(x, character(0))) NA_character_ else x
            })
            geocode[[i]] <- lapply(geocode[[i]],function(x) {
              if(identical(x, list())) NA_character_ else x
            })
          }
          tmp <- bind_cols(tmp, geocode)
          tmp$location <- as.character(tmp$location)
          dat <- bind_rows(dat, tmp)
        })
      }
      finaldat <- tidyr::separate(dat, "location", into = c("longitude", "latitude"), sep = ",")
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
