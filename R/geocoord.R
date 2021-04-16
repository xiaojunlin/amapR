#' @title Converting the addresses to coordinates
#' @description Converting the address to coordinates
#' @import jsonlite
#' @import progress
#' @import progressr
#' @import future.apply
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
    x <- gsub("__", "", x)
    x <- gsub("　", "", x)
    return(x)
  }

  vars_list <-  c('location','formatted_address', 'country', 'province', 'city',
                  'district', 'township', 'street', 'number', 'citycode', 'adcode')

  if (is.null(getOption("amap.key"))) stop("Please fill your key using 'options(amap.key = 'XXXXXXXXXXXXX')' ")
  key <- getOption("amap.key")

  if (length(address) <= 500) {
    query1 <- function(address, n = 10) {
      df <- as.data.frame(address)
      dat <- slice(df, 0)
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

          for (i in vars_list) {
            geocode[[i]] <- lapply(geocode[[i]],function(x) {
              if(identical(x, character(0))) NA_character_ else x
            })
            geocode[[i]] <- lapply(geocode[[i]],function(x) {
              if(identical(x, list())) NA_character_ else x
            })
          }

          tmp <- bind_cols(tmp, geocode) %>% mutate_all(as.character)
          dat <- bind_rows(dat, tmp)
        })
      }
      result <- tidyr::separate(dat, "location", into = c("longitude", "latitude"), sep = ",") %>%
        mutate_at(c("longitude", "latitude", "citycode", "adcode"), as.numeric)
      return(result)
    }
    query1(address, n)
  } else {
    query2 <- function(address, n = 10) {
      df <- as.data.frame(address)
      dat <- slice(df, 0)
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

          for (i in vars_list) {
            geocode[[i]] <- lapply(geocode[[i]],function(x) {
              if(identical(x, character(0))) NA_character_ else x
            })
            geocode[[i]] <- lapply(geocode[[i]],function(x) {
              if(identical(x, list())) NA_character_ else x
            })
          }

          tmp <- bind_cols(tmp, geocode) %>% mutate_all(as.character)
          dat <- bind_rows(dat, tmp)
        })
      }
      result <- tidyr::separate(dat, "location", into = c("longitude", "latitude"), sep = ",") %>%
        mutate_at(c("longitude", "latitude", "citycode", "adcode"), as.numeric)
      return(result)
    }

    spldata <- split(address, f = ceiling(seq(length(address)) / n))
    cores <- detectCores()
    cl <- makeCluster(cores)
    plan(cluster, workers = cl)
    xs <- seq_len(length(spldata))
    handlers(handler_progress(format="[:bar] :percent :eta :message"))
    with_progress({
      p <- progressor(along = xs)
      result <- future_lapply(xs, FUN = function(x){
        p()
        query2(unlist(spldata[[x]]))
      })
    })
    results <- bind_rows(result)
    return(results)
  }
}
