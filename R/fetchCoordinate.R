fetchCoordinate.core <- function(address){
  result <- matrix(nrow=length(address),ncol=3)
  colnames(result) <- c("address", "lon", "lat")
  for (i in 1:length(address)){
    addr <- gsub(" ", "", address[i])
    url = paste0("https://restapi.amap.com/v3/geocode/geo?address=", addr, "&output=json&key=", getOption('gaode.key'))
    web =  tryCatch(getURL(url),error = function(e) {getURL(url, timeout = 200)})
    res <- gsub('.*?"location":"([\\.,0-9]*).*', '\\1', web)
    lon = as.numeric(strsplit(res, ",")[[1]][1])
    lat = as.numeric(strsplit(res, ",")[[1]][2])
    result[i,]  <- c("address"= addr, "longitude" = lon, "latitude" = lat)
  }
  return(result)
}

#' Title
#' @title fetchCoordinate
#' @description fetch coordinate based on address
#' @import RCurl
#' @param address The address
#' @return a matrix
#' @export fetchCoordinate
#' @examples
#' library(gaodemap)
#' options(gaode.key = 'xxxxxxxxxxxxxxxx')
#'
#' address = c('四川大学','北京大学','aaa',NA)
#'
#' coordinate <-fetchCoordinate(address)
#'
fetchCoordinate <- function(address){
  # key
  if (is.null(getOption('gaode.key'))) stop("Please fill your key using options(gaode.key = 'XXXXXXXXXXXXX')")

  if(length(address)<=10){
    res<-fetchCoordinate.core(address)
  }else if(require(parallel)){
    res<-mclapply(X = address, FUN = function(x){fetchCoordinate.core(x)},
                  mc.cores = getOption("mc.cores", detectCores()*6),
                  mc.preschedule = FALSE)  # for macOS
    res<-do.call('rbind', res)
  }else{
    warning('can not run in parallel mode without package parallel')
    res<-fetchCoordinate.core(address)
  }
  res
}
