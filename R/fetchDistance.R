#' Title
#' @title fetchDistance
#' @description calculate the distance and travel time between origins and destinations
#' @import progress
#' @import dplyr
#' @import httr
#' @import jsonlite
#' @import stringr
#' @param origin A vector of the coordinates of the origins. The formate should be "longtitude, latitude"
#' @param dest A vetor of the coordinates of the destinations. The formate should be "longtitude, latitude"
#' @param type Travel way (0 = direct distance, 2 = drive car; 3 = wall (only support the distance within 5km))
#' @return a dataframe including origins coordinates, destinations coordinates, distance (meters) and travel time (seconds).
#' @export
#' @examples
#' library(gaodemap)
#' options(gaode.key = 'xxxxxxxxxxxxxxxx')
#'
#' data <- data.frame(
#' origin = c("118.796877,32.060255", "114.3054,45.222", "114.777,33.123", "116.12223,35.333"),
#' dest   = c("121.473701,31.230416", "122.44221,30.2223", "NA,NA",       "99999,66666")
#' )
#'
#' fetchDistance(origin = data$origin, dest = data$dest, type = '0') # direct distance
#' fetchDistance(origin = data$origin, dest = data$dest, type = '1') # travel time by driving a car
#'
#' fetchDistance(origin = data$origin, dest = c("118.796877, 34.1234"), type = '1')

fetchDistance <- function(origin, dest, type){
  url = "https://restapi.amap.com/v3/distance?parameters"
  header  <- c("User-Agent"="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36")
  payload = list(
    'output' = 'json',
    'key' = getOption('gaode.key')
  )
  if (is.null(getOption('gaode.key'))) stop("Please fill your key, using [ options(gaode.key = 'XXXXXXXXXXXXX') ]")
  distinfo <- data.frame(origin = c(), dest = c(), distance = c(), time =c())
  pb <- progress_bar$new(format = "Fetching travel distance: [:bar] :current/:total (:percent)",
                         total = length(origin)*length(dest))
  pb$tick(0)
  for (j in 1:length(dest)){
    for (i in 1:length(origin)) {
      payload[['origins']]     = gsub(" ", "", origin[i])
      payload[['destination']] = gsub(" ", "", dest[j])
      payload[['type']] = type
      tryCatch({
        web = GET(url, add_headers(.headers = header), query = payload) %>% content(as="text",encoding="UTF-8") %>% fromJSON(flatten = TRUE)
        if(web$status ==  1 & "info" %in% names(web$results) == F){
          content <-  data.frame(
            origin = gsub(" ", "", origin[i]),
            dest   = gsub(" ", "", dest[j]),
            distance = web$results$distance %>% as.numeric(), # unit: meter
            time = web$results$duration %>% as.numeric()     # unit: second
          )
        } else {
          content <- data.frame(
            origin = gsub(" ", "", origin[i]),
            dest   = gsub(" ", "", dest[j]),
            distance = NA, # unit: meter
            time = NA      # unit: second
          )
        }
        distinfo <- rbind(distinfo, content)
      },error = function(e){
        content <- data.frame(
          origin = gsub(" ", "", origin[i]),
          dest   = gsub(" ", "", dest[j]),
          distance = NA, # unit: meter
          time = NA      # unit: second
        )
        distinfo <- rbind(distinfo, content)
      })

      pb$tick(1)
      Sys.sleep(1 / 100)
    }
  }
  print("Done!")
  return(distinfo)
}
