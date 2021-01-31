#' Title
#' @title fetchCoordinate
#' @description get coordinate based on address
#' @import jsonlite
#' @import progress
#' @import tidyverse
#' @param address The address
#' @param n The number of batch query, n = 10 by default
#' @return a data.frame
#' @export fetchCoordinate
#' @examples
#' library(amap)
#' options(amap.key = "xxxxxxxxxxxxxxxxxx")
#'
#' fetchCoordinate("四川大学")
#' fetchCoordinate(c("四川大学", "华中科技大学))
#'
#' dat <- data.frame(Number= 1:500,
#'                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学",
#'                             "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))
#' system.time(z1 <- fetchCoordinate(dat$address))
#' system.time(z2 <- fetchCoordinate(dat$address, n =5))
#'
fetchCoordinate<- function(address, n = 10){

  if (is.null(getOption('amap.key'))) stop("Please fill your key using 'options(amap.key = 'XXXXXXXXXXXXX')' ") # Check key
  if (n > 10 | n <= 0 | is.numeric(n) == F) stop("The argument of n should range between 1 to 10.") # Batch query is supported for up to 10 addresses.

  df <- as.data.frame(address)
  dat <- slice(df, 0)
  dat$coordinate <- NULL

  pb <- progress_bar$new(format = "Processing: [:bar] :percent eta: :eta", total =  length(seq(1, nrow(df), by = n)))
  pb$tick(0)

  for (i in seq(1, nrow(df), by = n)) {
    pb$tick(1)
    try({
      j = i + n - 1
      tmp <- df %>% slice(i:j)
      url <- tmp %>% pull(address) %>% paste0(collapse = "|") %>% paste0("https://restapi.amap.com/v3/geocode/geo?address=", ., "&key=", getOption('amap.key'), "&batch=true")
      list <- fromJSON(URLencode(url))
      list$geocodes %>% as_tibble() %>% select(coordinate = location) %>% bind_cols(tmp, .) -> tmp
      tmp$coordinate <- as.character(tmp$coordinate)
      dat <- bind_rows(dat, tmp)
    })
  }

  finaldat <- dat %>% tidyr::separate("coordinate", into = c("longitude", "latitude"), sep = ",") %>%
    mutate(longitude = as.numeric(longitude),
           latitude = as.numeric(latitude))

  return(finaldat)
}
