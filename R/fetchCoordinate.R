fetchCoordinate.core <- function(data){
  # key
  if (is.null(getOption('gaode.key'))) stop("Please fill your key using options(gaode.key = 'XXXXXXXXXXXXX')")

  result <- matrix(nrow=length(data),ncol=3)
  colnames(result) <- c("address", "lon", "lat")

  for (i in 1:length(data)){
    addr <- gsub(" ", "", data[i])
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
#' @import httr
#' @param data The address
#' @return a dataframe
#' @export fetchCoordinate
#' @examples
#' library(gaodemap)
#' options(gaode.key = 'xxxxxxxxxxxxxxxx')
#'
#' address = c('北京市朝阳区望京东路4号横店大厦','北京市海淀区上地信息路9号奎科科技大厦','aaa',NA)
#'
#' coordinate <-fetchCoordinate(address)
#'
fetchCoordinate <- function(address){
  # key
  if (is.null(getOption('gaode.key'))) stop("Please fill your key using options(gaode.key = 'XXXXXXXXXXXXX')")

  if(length(address)<=10){
    res<-fetchCoordinate.core(address)
  }else if(require(parallel)){
    res<-mclapply(mc.cores = getOption("mc.cores", detectCores()*10), X = address, FUN = function(x){fetchCoordinate.core(x)})  #mclapply for macOS
    res<-do.call('rbind', res)
  }else{
    warning('can not run in parallel mode without package parallel')
    res<-fetchCoordinate.core(address)
  }
  res
}

