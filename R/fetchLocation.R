#' Title
#' @title fetchLocation
#' @description fetch location based on longitude and latitude
#' @import progress
#' @import dplyr
#' @import httr
#' @import jsonlite
#' @import stringr
#' @param lon the longitude
#' @param lat the latitude
#' @return a data frame
#' @export
#' @examples
#' library(amap)
#' options(amap.key = 'xxxxxxxxxxxxxxxx')
#'
#' coordinate = data.frame(
#'   lat = c(39.934,40.013,40.047,NA,4444),
#'     lon = c(116.329,116.495,116.313,NA,6666)
#'     )
#'
#'  address <- fetchLocation(lon = coordinate$lon, lat = coordinate$lat)
#'  address <- fetchLocation(lon = 104.0665, lat = 30.57227)
#'
#'
fetchLocation <- function(lon, lat){
  url = "https://restapi.amap.com/v3/geocode/regeo?parameters"
  header = c('User-Agent'= 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36')
  payload = list(
    'output' = 'json',
    'key'    = getOption('amap.key')
  )
  if (is.null(getOption('amap.key'))) stop("Please fill your key, using 'options(amap.key = 'XXXXXXXXXXXXX')' ")
  addinfo = data.frame(address = c(), lon = c(), lat = c())
  pb <- progress_bar$new(format = "Fetching location: [:bar] :current/:total (:percent)",
                         total = length(lon))
  pb$tick(0)
  for (i in 1:length(lon)){
    payload[['location']] = sprintf('%.3f,%.3f', lon[i], lat[i])
    tryCatch({
      web <-  GET(url,add_headers(.headers = header),query = payload)  %>% content(as="text",encoding="UTF-8")  %>% fromJSON(flatten = TRUE)
      if(length(web$regeocode$formatted_address) > 0 ){
        content <-  data.frame(
          address = web$regeocode$formatted_address,
          lon = lon[i],
          lat = lat[i]
        )
      } else {
        content <-data.frame(
          address = NA,
          lon = lon[i],
          lat = lat[i]
        )
      }
      addinfo <- rbind(addinfo, content)
    },error = function(e){
      content <-data.frame(
        address = NA,
        lon = lon[i],
        lat = lat[i]
      )
      addinfo <- rbind(addinfo, content)
    })
    pb$tick(1)
    Sys.sleep(1 / 100)
  }
  print("Done!")
  return(addinfo)
}
