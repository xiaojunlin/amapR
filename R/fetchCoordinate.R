#' Title
#' @title fetchCoordinate
#' @description get coordinate based on address
#' @import RCurl
#' @import progress
#' @param address The address
#' @return a data.frame
#' @export fetchCoordinate
#' @examples
#' library(gaodemap)
#'
#' x <- data.frame(Number= 1:500,
#'                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))
#'
#'system.time(z <- fetchCoordinate(x$address))
#'
#'fetchCoordinate("四川大学")
#'
fetchCoordinate <- function(address){
  # key
  if (is.null(getOption('gaode.key'))) stop("Please fill your key using options(gaode.key = 'XXXXXXXXXXXXX')")
  # url
  url <- paste0("https://restapi.amap.com/v3/geocode/geo?address=", address, "&output=json&key=", getOption('gaode.key'))
  res <- c()
  # QPS limitation: no more than 200 queries per second. Thus, we split the urls into groups with no more than 190 cases
  group_url<- split(url, ceiling(seq_along(url)/190))
  pb <- progress_bar$new(format = "Processing: [:bar] :percent", total =  length(group_url))
  pb$tick(0)
  for (i in 1:length(group_url)) {
    res_add <- getURIAsynchronous(group_url[[i]])
    res <- c(res, res_add)
    pb$tick(1)
    Sys.sleep(1/10)
  }
  #transform
  trans <-function(x){
    res = gsub('.*?"location":"([\\.,0-9]*).*', '\\1', x)
    lon = as.numeric(strsplit(res, ",")[[1]][1])
    lat = as.numeric(strsplit(res, ",")[[1]][2])
    return(c("address" = "" ,"longitude" = lon, "latitude" = lat))
  }
  res <- t(sapply(res, trans))
  res <- as.data.frame(res)
  rownames(res) <- NULL
  res$address <- address

  return(res)
}
