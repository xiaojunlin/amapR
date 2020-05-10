
#' Title
#' @title fetchCoordinate
#' @description fetch coordinate based on address
#' @import progress
#' @import dplyr
#' @import httr
#' @import jsonlite
#' @import stringr
#' @param data The address
#' @return a dataframe
#' @export
#' @examples
#' address = c('北京市朝阳区望京东路4号横店大厦','北京市海淀区上地信息路9号奎科科技大厦','aaa',NA)
#'
#' coordinate <-fetchCoordinate(address)
#'
fetchCoordinate <- function(data){
  url = "https://restapi.amap.com/v3/geocode/geo?parameters"
  header  <- c("User-Agent"="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36")
  payload = list(
    'output' = 'json',
    'key' = getOption('gaode.key')
  )
  if (is.null(getOption('gaode.key'))) stop("Please fill your key, using [ options(gaode.key = 'XXXXXXXXXXXXX') ]")
  addinfo <- list()
  pb <- progress_bar$new(format = "Fetching coordinate: [:bar] :current/:total (:percent)",
                         total = length(data))
  pb$tick(0)
  for (i in data){
    payload[["address"]] = i
    tryCatch({
      web <- GET(url,add_headers(.headers = header),query = payload) %>% content(as="text",encoding="UTF-8") %>% fromJSON(flatten = TRUE) %>% .$geocodes
      if(length(web)  > 0){
        content <- web  %>% .$location %>% str_split(',') %>% `[[`(1)
      }else{
        content <- c(NA,NA)
      }
      addinfo <- rbind(addinfo,content)
    },error = function(e){
      addinfo <- rbind(addinfo,c(NA,NA))
    })
    pb$tick(1)
    Sys.sleep(1 / 100)
  }
  result_data <- addinfo %>% matrix(ncol=2) %>% data.frame(address = data, stringsAsFactors = F)  %>% rename(lon =X1,lat = X2 )
  result_data$lon <- as.numeric(result_data$lon)
  result_data$lat <- as.numeric(result_data$lat)
  print("Done!")
  return(result_data)
}
