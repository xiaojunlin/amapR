#' Title
#' @title geodist
#' @description calculate the distance and travel time between origins and destinations
#' @import progress
#' @import dplyr
#' @import httr
#' @import jsonlite
#' @import stringr
#' @param data the data set
#' @param lon1 the longitude of the original point
#' @param lat1 the latitude of the original point
#' @param lon2 the longitude of the destination point
#' @param lat2 the latitude of the destination point
#' @param type the travel methods (0 = direct distance, 2 = drive car; 3 = walk (only support the distance within 5km))
#' @return a data frame including origin coordinates, destination coordinates, distance (meters) and travel time (seconds).
#' @export geodist
#' @examples
#' library(amap)
#' options(amap.key = 'xxxxxxxxxxxxxxxx')
#' x <- data.frame(
#' a = c(104.0141, 104.0518, 104.0644, 104.0390, 104.1890,  NA),
#' b = c(30.66794, 30.64201, 30.64035, 30.66362, 30.65145,  NA),
#' c = c(104.0652, 104.0652, 104.0652, 104.0652, 104.0652,  104.0652),
#' d = c(30.57851, 30.57851, 30.57851, 30.57851, 30.57851,  30.57851)
#' )
#' y <- geodist(data = x, lon1 = "a" , lat1 = "b", lon2 = "c", lat2 ="d", type = 0)
#' z <- geodist(data = x, lon1 = "a" , lat1 = "b", lon2 = "c", lat2 ="d", type = 1)
#'
#'
#'
geodist <- function(data, lon1, lat1, lon2, lat2, type){
  url = "https://restapi.amap.com/v3/distance?parameters"
  header  <- c("User-Agent"="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36")
  payload = list(
    'output' = 'json',
    'key' = getOption('amap.key')
  )
  if (is.null(getOption('amap.key'))) stop("Please fill your key, using 'options(amap.key = 'XXXXXXXXXXXXX')' ")


  distinfo <- data.frame(lon1= c(), lat1=c(), lon2 = c(), lat2= c(), distance = c(), time =c())
  pb <- progress_bar$new(format = "Fetching travel distance: [:bar] :current/:total (:percent)",
                         total = nrow(data))
  pb$tick(0)

  for (i in 1:nrow(data)){
    orig = paste(data[lon1][i,], data[lat1][i,], sep=",")
    dest = paste(data[lon2][i,], data[lat2][i,], sep=",")

    payload[['origins']]     = orig
    payload[['destination']] = dest
    payload[['type']] = type
    tryCatch({
      web = GET(url, add_headers(.headers = header), query = payload) %>% content(as="text",encoding="UTF-8") %>% fromJSON(flatten = TRUE)
      if(web$status ==  1 & "info" %in% names(web$results) == F){
        content <-  data.frame(
          origin = orig,
          dest   = dest,
          distance = web$results$distance %>% as.numeric(), # unit: meter
          time = web$results$duration %>% as.numeric()     # unit: second
        )
      } else {
        content <- data.frame(
          origin = orig,
          dest   = dest,
          distance = NA, # unit: meter
          time = NA      # unit: second
        )
      }
      distinfo <- rbind(distinfo, content)
    },error = function(e){
      content <- data.frame(
        origin = orig,
        dest   = dest,
        distance = NA, # unit: meter
        time = NA      # unit: second
      )
      distinfo <- rbind(distinfo, content)
    })

    pb$tick(1)
    Sys.sleep(1 / 100)
  }

  return(distinfo)
}
