#' Title
#' @title fetchLocation
#' @description fetch location based on longtitude and latitude
#' @import progress
#' @import dplyr
#' @import httr
#' @import jsonlite
#' @import stringr
#' @param data name of the data, dataframe
#' @param lon the longtidute
#' @param lat the latitude
#' @return a dataframe
#' @export
#' @examples
#' testdata = data.frame(
#' lat = c(39.934,40.013,40.047,NA,4444),
#' lon = c(116.329,116.495,116.313,NA,6666)
#' )
#' address <- fetchLocation(testdata, lon = 'lon', lat = 'lat')
#'
#'
fetchLocation <- function(data, lon, lat){
  url = "https://restapi.amap.com/v3/geocode/regeo?parameters"
  header = c('User-Agent'= 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36')
  payload = list(
    'output' = 'json',
    'key'    = getOption('gaode.key')
  )
  if (is.null(getOption('gaode.key'))) stop("Please fill your key, using [ options(gaode.key = 'XXXXXXXXXXXXX') ]")
  addinfo = c()
  pb <- progress::progress_bar$new(format = "Fetching location: [:bar] :current/:total (:percent)",
                         total = nrow(data))
  pb$tick(0)
  for (i in 1:nrow(data)){
    payload[['location']] = sprintf('%.3f,%.3f',data[i,'lon'],data[i,'lat'])
    tryCatch({
      web <-  GET(url,add_headers(.headers = header),query = payload)  %>% content(as="text",encoding="UTF-8")  %>% fromJSON(flatten = TRUE)
      if(length(web$regeocode$formatted_address) > 0 ){
        content <-  web  %>% .$regeocode %>% .$formatted_address
      } else {
        content <-NA
      }
      addinfo <- content %>% c(addinfo,.)
    },error = function(e){
      addinfo <- c(addinfo,NA)
    })
    pb$tick(1)
    Sys.sleep(1 / 100)
  }
  print("Done!")
  cbind(addinfo,data) %>% return()
}
