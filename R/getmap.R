#' @title Getting the map data with sf format
#' @description Getting the map data with sf format
#' @import sf
#' @importFrom dplyr select filter %>% rename
#' @import foreach
#' @import doSNOW
#' @param adcode The administrative code
#' @param level The level of map data, including province, city and district
#' @return sf data
#' @export getmap
#' @examples
#' \dontrun{
#' library(ggplot2)
#' # China map
#' # (1) China map at province level
#' china <- getmap(adcode = 100000, level = "province")
#' ggplot(china) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (2) China map at city level
#' china <- getmap(adcode = 100000, level = "city")
#' ggplot(china) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (3) China map at district level
#' china <- getmap(adcode = 100000, level = "district")
#' ggplot(china) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (4) missing value in the argment "level"
#' china4 <- getmap(adcode = 100000)
#' ggplot(china) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#'
#' # Sichuan
#' # (1) map at province level
#' sichuan <- getmap(adcode = 510000, level = "province")
#' ggplot(sichuan) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (2) map at city level
#' sichuan <- getmap(adcode = 510000, level = "city")
#' ggplot(sichuan) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (3) map at district level
#' sichuan <- getmap(adcode = 510000, level = "district")
#' ggplot(sichuan) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#'
#' # Chengdu
#' # (1) map at city level
#' chengdu <- getmap(adcode = 510100, level = "city")
#' ggplot(chengdu) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (2) fetch and map at district level
#' chengdu <- getmap(adcode = 510100, level = "district")
#' ggplot(chengdu) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' }
getmap <- function(adcode, level = "default") {
  if (adcode == 100000) {
    switch(level,
           province = {
             map_province <- read_sf("https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json") %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             map <- map_province
           },
           city = {
             # Provincial map
             map_province <- read_sf("https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json") %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             tmp <- select(map_province, c(adcode, name_province)) %>% filter(adcode != "100000" & adcode != "710000")
             dash_line <- filter(map_province, adcode == "100000") %>% select(c(adcode, name_province, level))
             dash_line$name_city <- NA
             dash_line$name_district <- NA
             dash_line1 <- select(dash_line, c(adcode, name_province, name_city, level))
             dash_line2 <- select(dash_line, c(adcode, name_province, name_city, name_district, level))
             # Taiwan
             taiwan <- filter(map_province, adcode == "710000") %>% select(c(adcode, name_province, level))
             taiwan$name_city <- NA
             taiwan$name_district <- NA
             taiwan1 <- select(taiwan, c(adcode, name_province, name_city, level))
             taiwan2 <- select(taiwan, c(adcode, name_province, name_city, name_district, level))
             # City-level map
             cores <- min((detectCores() - 1), 999)
             cl <- makeCluster(cores)
             registerDoSNOW(cl)
             map_city <- foreach(i = 1:nrow(tmp), .combine = "rbind") %dopar% {
               submap <- sf::read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", tmp$adcode[i], "_full.json"))
               submap <- submap[, c("adcode", "name", "level")]
               submap$name_province <- tmp$name_province[i]
               submap$name_city <- submap$name
               submap
             }
             stopCluster(cl)
             map <- rbind(select(map_city, c(adcode, name_province, name_city, level)), taiwan1) %>% rbind(dash_line1)
           },
           district = {
             # Provincial map
             map_province <- read_sf("https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json") %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             tmp <- select(map_province, c(adcode, name_province)) %>% filter(adcode != "100000" & adcode != "710000")
             dash_line <- filter(map_province, adcode == "100000") %>% select(c(adcode, name_province, level))
             dash_line$name_city <- NA
             dash_line$name_district <- NA
             dash_line1 <- select(dash_line, c(adcode, name_province, name_city, level))
             dash_line2 <- select(dash_line, c(adcode, name_province, name_city, name_district, level))
             # Taiwan
             taiwan <- filter(map_province, adcode == "710000") %>% select(c(adcode, name_province, level))
             taiwan$name_city <- NA
             taiwan$name_district <- NA
             taiwan1 <- select(taiwan, c(adcode, name_province, name_city, level))
             taiwan2 <- select(taiwan, c(adcode, name_province, name_city, name_district, level))
             # City-level map
             cores <- min((detectCores() - 1), 999)
             cl <- makeCluster(cores)
             registerDoSNOW(cl)
             map_city <- foreach(i = 1:nrow(tmp), .combine = "rbind") %dopar% {
               submap <- sf::read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", tmp$adcode[i], "_full.json"))
               submap <- submap[, c("adcode", "name", "level")]
               submap$name_province <- tmp$name_province[i]
               submap$name_city <- submap$name
               submap
             }
             stopCluster(cl)
             map_city <- rbind(select(map_city, c(adcode, name_province, name_city, level)), taiwan1) %>% rbind(dash_line1)
             # District-level map
             # (1) municipality or special administrative region
             map_district0 <- map_city %>% filter(level == "district")
             map_district0$name_district <- map_district0$name_city
             map_district0$name_city <- NA
             map_district0 <- select(map_district0, c(adcode, name_province, name_city, name_district, level))
             # (2) other cities with districts
             tmp <- filter(map_city, level == "city") %>% select(c(adcode, name_province, name_city))
             cores <- min((detectCores() - 1), 999)
             cl <- makeCluster(cores)
             registerDoSNOW(cl)
             map_district1 <- foreach(i = 1:nrow(tmp), .combine = "rbind") %dopar% {
               submap <- tryCatch({sf::read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/",tmp$adcode[i], "_full.json"))},
                                  warning = function(w){sf::read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", tmp$adcode[i], ".json"))})
               submap <- submap[, c("adcode", "name", "level")]
               submap$name_province <- tmp$name_province[i]
               submap$name_city <- tmp$name_city[i]
               submap$name_district <- submap$name
               submap
             }
             stopCluster(cl)
             map <- rbind(map_district0, select(map_district1, c(adcode, name_province, name_city, name_district, level))) %>% rbind(taiwan2) %>% rbind(dash_line2)
           },
           default = {
             map_province <- read_sf("https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json") %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             map <- map_province
           }
    )
  } else if (substr(adcode, 3, 4) == "00" & substr(adcode, 1, 2) %in% c(11, 12, 31, 50, 81, 82) == F) {
    switch(level,
           province = {
             map_province <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, ".json")) %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             map <- map_province
           },
           city = {
             map_city <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, "_full.json")) %>% select(c(adcode, name, level))
             map_city <- rename(map_city, "name_city" = "name")
             map <- map_city
           },
           district = {
             map_city <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, "_full.json")) %>% select(c(adcode, name, level))
             map_city <- rename(map_city, "name_city" = "name")
             tmp <- filter(map_city, level == "city") %>% select(c(adcode, name_city))
             cores <- min((detectCores() - 1), 999)
             cl <- makeCluster(cores)
             registerDoSNOW(cl)
             map_district <- foreach(i = 1:nrow(tmp), .combine = "rbind") %dopar% {
               submap <- tryCatch({sf::read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/",tmp$adcode[i], "_full.json"))},
                                  warning = function(w){sf::read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", tmp$adcode[i], ".json"))})
               submap <- submap[, c("adcode", "name", "level")]
               submap$name_city <- tmp$name_city[i]
               submap$name_district <- submap$name
               submap
             }
             stopCluster(cl)
             map <- select(map_district, c(adcode, name_city, name_district,level))
           },
           default = {
             map_city <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, "_full.json")) %>% select(c(adcode, name, level))
             map_city <- rename(map_city, "name_city" = "name")
             map <- map_city
           }
    )
  } else if (substr(adcode, 3, 4) == "00" & substr(adcode, 1, 2) %in% c(11, 12, 31, 50, 81, 82) == T) {
    switch(level,
           province = {
             map_province <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, ".json")) %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             map <- map_province
           },
           city = {
             message("The argument of level is not allowed for the municipality or special administrative region, please use 'level = district'.")
           },
           district = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, "_full.json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           },
           default = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, "_full.json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           }
    )
  } else if (substr(adcode, 3, 4) != "00" & substr(adcode, 5, 6) == "00") {
    switch(level,
           province = {
             message("Error in the argument of 'level'. Please use 'level = 'city'.")
           },
           city = {
             map_city <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, ".json")) %>% select(c(adcode, name, level))
             map_city <- rename(map_city, "name_city" = "name")
             map <- map_city
           },
           district = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, "_full.json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           },
           default = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, "_full.json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           }
    )
  } else {
    switch(level,
           province = {
             message("Error in the argument of 'level'. Please use 'level = 'district'.")
           },
           city = {
             message("Error in the argument of 'level'. Please use 'level = 'district'.")
           },
           district = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, ".json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           },
           default = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v3/bound/", adcode, ".json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           }
    )
  }

  return(map)
}
