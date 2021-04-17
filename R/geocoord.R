#' @title Converting the addresses to coordinates
#' @description Converting the address to coordinates
#' @importFrom data.table as.data.table
#' @import jsonlite
#' @import progress
#' @import progressr
#' @import future
#' @import future.apply
#' @import dplyr
#' @import tidyr
#' @import stringr
#' @param address The address
#' @return data.table
#' @export geocoord
#' @examples
#' library(amap)
#' options(amap.key = "xxxxxxxxxxxxxxxxxx")
#' geocoord("address in Chinese format")

geocoord <- function(address) {

  vars_list <-  c('location','formatted_address', 'country', 'province', 'city',
                  'district', 'township', 'street', 'number', 'citycode', 'adcode')

  if (is.null(getOption("amap.key"))) stop("Please fill your key using 'options(amap.key = 'XXXXXXXXXXXXX')' ")
  key <- getOption("amap.key")

  if (length(address) <= 500) {
    query1 <- function(address) {
      df <- as.data.frame(address)
      dat <- slice(df, 0)
      pb <- progress_bar$new(format = "[:bar] :percent :eta", total = length(seq(1, nrow(df), by = 10)))
      pb$tick(0)
      for (i in seq(1, nrow(df), by = 10)) {
        pb$tick(1)
        try({
          j <- i + 9
          tmp <- slice(df, i:j)
          tmp_trim <- str_replace_all(tmp$address, "[^[:alnum:]]", "_") %>% as.data.frame()
          colnames(tmp_trim) <- "address"
          url <- paste0("https://restapi.amap.com/v3/geocode/geo?", "key=", key, "&batch=true",
                        "&address=", paste0(pull(tmp_trim, address), collapse = "|"))
          list <- fromJSON(url)
          geocode <- list$geocodes %>% select(all_of(vars_list))
          # replace character(0) and list() with NA
          for (k in vars_list) {
            geocode[[k]] <- lapply(geocode[[k]],function(x) {
              if(identical(x, character(0))) NA_character_ else x
            })
            geocode[[k]] <- lapply(geocode[[k]],function(x) {
              if(identical(x, list())) NA_character_ else x
            })
          }
          tmp <- bind_cols(tmp, geocode) %>% mutate_all(as.character)
          dat <- bind_rows(dat, tmp)
        })
      }
      result <- separate(dat, "location", into = c("longitude", "latitude"), sep = ",") %>%
        mutate_at(c("longitude", "latitude"), as.numeric) %>% as.data.table()
      return(result)
    }
    query1(address)
  } else {
    query2 <- function(address) {
      df <- as.data.frame(address)
      dat <- slice(df, 0)
      for (i in seq(1, nrow(df), by = n)) {
        try({
          tmp <- slice(df, 1:nrow(df))
          tmp_trim <- str_replace_all(tmp$address, "[^[:alnum:]]", "_") %>% as.data.frame()
          colnames(tmp_trim) <- "address"
          url <- paste0("https://restapi.amap.com/v3/geocode/geo?", "key=", key, "&batch=true",
                        "&address=", paste0(pull(tmp_trim, address), collapse = "|"))
          list <- fromJSON(url)
          if (nrow(df) == 1 & identical(list(), list$geocodes) == TRUE) {
            geocode <- data.frame(location = NA, formatted_address = NA,  country = NA,  province = NA,
                                  city = NA, district = NA, township = NA, street = NA,  number = NA,
                                  citycode = NA, adcode = NA)
          } else {
            geocode <- list$geocodes %>% select(all_of(vars_list))
            for (k in vars_list) {
              geocode[[k]] <- lapply(geocode[[k]],function(x) {
                if(identical(x, character(0))) NA_character_ else x
              })
              geocode[[k]] <- lapply(geocode[[k]],function(x) {
                if(identical(x, list())) NA_character_ else x
              })
            }
          }
          tmp <- bind_cols(tmp, geocode) %>% mutate_all(as.character)
          dat <- bind_rows(dat, tmp)
        })
      }
      result <- separate(dat, "location", into = c("longitude", "latitude"), sep = ",") %>%
        mutate_at(c("longitude", "latitude"), as.numeric)
      return(result)
    }
    spldata <- split(address, f = ceiling(seq(length(address)) / 10))
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
    results <- bind_rows(result) %>% as.data.table()
    return(results)
  }
}
