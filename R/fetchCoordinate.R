#' Title
#' @title fetchCoordinate
#' @description get coordinate based on address
#' @import jsonlite
#' @import progress
#' @import tidyverse
#' @param address The address
#' @return a data.frame
#' @export fetchCoordinate
#' @examples
#' library(amap)
#' options(amap.key = "xxxxxxxxxxxxxxxxxx")
#' x <- data.frame(Number= 1:500,
#'                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))
#'
#'system.time(z <- fetchCoordinate(x$address))
#'
#'fetchCoordinate("四川大学")
#'
#'
#'
fetchCoordinate <- function(address){

  if (is.null(getOption('amap.key'))) stop("Please fill your key using 'options(amap.key = 'XXXXXXXXXXXXX')' ")

  df <- as.data.frame(address)
  dat <- slice(df, 0)
  dat$coordinate <- NULL

  pb <- progress_bar$new(format = "Processing: [:bar] :percent eta: :eta", total =  length(seq(1, nrow(df), by = 10)))
  pb$tick(0)

  for (i in seq(1, nrow(df), by = 10)) {
    pb$tick(1)
    try({
      j = i + 9
      tmp <- df %>% slice(i:j)
      url <- tmp %>%
        pull(address) %>%
        paste0(collapse = "|") %>%
        paste0("https://restapi.amap.com/v3/geocode/geo?address=", ., "&key=", getOption('amap.key'), "&batch=true")
      list <- fromJSON(URLencode(url))
      list$geocodes %>%
        as_tibble() %>%
        select(coordinate = location) %>%
        bind_cols(tmp, .) -> tmp
      tmp$coordinate <- as.character(tmp$coordinate)
      dat <- bind_rows(dat, tmp)
    })
  }

  finaldat <- dat %>%
    tidyr::separate("coordinate", into = c("longitude", "latitude"), sep = ",") %>%
    mutate(longitude = as.numeric(longitude),
           latitude = as.numeric(latitude))

  return(finaldat)
}
