#' Title
#' @title geomap
#' @description Get the map data with sf format
#' @import sf
#' @import tidyverse
#' @param adcode The administrative code
#' @param level The level of map data, including province, city and district
#' @return sf data
#' @export geomap
#' @examples
#' library(amap)
#' options(amap.key = "xxxxxxxxxxxxxxxxxx")
#'
#' # China map
#' # (1) fetch and map at province level
#' china1 <- geomap(adcode = 100000, level = "province")
#' ggplot(china1) +
#'  geom_sf(fill = "white") +
#'  theme_bw()
#' # (2) fetch and map at city level
#' china2 <- geomap(adcode = 100000,  level = "city")
#' ggplot(china2) +
#'  geom_sf(fill = "white") +
#'  theme_bw()
#' # (3) fetch and map at district level
#' china3 <- geomap(adcode = 100000,  level = "district")
#' ggplot(china3) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (4) fetch and map with missing value in the argment "level"
#' china4 <- geomap(adcode = 100000)
#' ggplot(china4) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#'
#' # Province map
#' # (1) fetch and map at province level
#' sichuan1 <- geomap(adcode = 510000, level = "province")
#' ggplot(sichuan1) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (2) fetch and map at city level
#' sichuan2 <- geomap(adcode = 510000, level = "city")
#' ggplot(sichuan2) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' #Note: The argument of level is not allowed for the municipality or special administrative region, please use 'level = district'.
#' beijing1 <- geomap(adcode = 110000, level = "city")
#' beijing2 <- geomap(adcode = 110000, level = "district")
#' ggplot(beijing2) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (3) fetch and map at district level
#' sichuan3 <- geomap(adcode = 510000, level = "district")
#' ggplot(sichuan3) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (4) fetch and map with missing value in the argment "level"
#' sichuan4 <- geomap(adcode = 510000)
#' ggplot(sichuan4) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#'
#' # City map
#' # (1) fetch and map at city level
#' chengdu1 <- geomap(adcode = 510100, level = "city")
#' ggplot(chengdu1) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (2) fetch and map at district level
#' chengdu2 <- geomap(adcode = 510100, level = "district")
#' ggplot(chengdu2) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#' # (3) fetch and map with missing value in the argment "level"
#' chengdu3 <- geomap(adcode = 510100)
#' ggplot(chengdu3) +
#'   geom_sf(fill = "white") +
#'   theme_bw()
#'
#'
#'
#'

geomap<- function(adcode, level = "default"){
  if (adcode == 100000) {
    switch(level,
           province = {
             map_province <- read_sf("https://geo.datav.aliyun.com/areas_v2/bound/100000_full.json") %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             map <- map_province
           },
           city = {
             # 省级地图
             map_province <- read_sf("https://geo.datav.aliyun.com/areas_v2/bound/100000_full.json") %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             tmp <- select(map_province, c(adcode, name_province)) %>% filter(adcode != "100000") # save adcode and province name
             #十段线
             dash_line <- filter(map_province, adcode == "100000") %>% select(c(adcode, name_province, level))
             dash_line$name_city <- NA
             dash_line$name_district <- NA
             dash_line1 <- select(dash_line, c(adcode, name_province, name_city, level))
             dash_line2 <- select(dash_line, c(adcode, name_province, name_city, name_district, level))
             #台湾
             taiwan <- filter(map_province, adcode == "710000") %>% select(c(adcode, name_province, level))
             taiwan$name_city <- NA
             taiwan$name_district <- NA
             taiwan1 <- select(taiwan, c(adcode, name_province, name_city, level))
             taiwan2 <- select(taiwan, c(adcode, name_province, name_city, name_district, level))
             #地市级地图
             map_city <- c()
             for (i in 1:nrow(tmp)){
               url <- paste0("https://geo.datav.aliyun.com/areas_v2/bound/", tmp$adcode[i], "_full.json")
               addmap <- read_sf(url) %>% select(c(adcode, name, level))
               addmap$name_province <- tmp$name_province[i]
               addmap$name_city <- addmap$name
               map_city <- rbind(map_city, addmap)
             }
             map_city <- select(map_city, c(adcode, name_province, name_city, level))
             map_city <- rbind(map_city, dash_line1)
             map <- map_city
           },
           district = {
             # 省级地图
             map_province <- read_sf("https://geo.datav.aliyun.com/areas_v2/bound/100000_full.json") %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             tmp <- select(map_province, c(adcode, name_province)) # save adcode and province name
             #十段线
             dash_line <- filter(map_province, adcode == "100000") %>% select(c(adcode, name_province, level))
             dash_line$name_city <- NA
             dash_line$name_district <- NA
             dash_line1 <- select(dash_line, c(adcode, name_province, name_city, level))
             dash_line2 <- select(dash_line, c(adcode, name_province, name_city, name_district, level))
             #台湾
             taiwan <- filter(map_province, adcode == "710000") %>% select(c(adcode, name_province, level))
             taiwan$name_city <- NA
             taiwan$name_district <- NA
             taiwan1 <- select(taiwan, c(adcode, name_province, name_city, level))
             taiwan2 <- select(taiwan, c(adcode, name_province, name_city, name_district, level))
             #地市级地图
             map_city <- c()
             for (i in 1:nrow(tmp)){
               url <- paste0("https://geo.datav.aliyun.com/areas_v2/bound/", tmp$adcode[i], "_full.json")
               addmap <- read_sf(url) %>% select(c(adcode, name, level))
               addmap$name_province <- tmp$name_province[i]
               addmap$name_city <- addmap$name
               map_city <- rbind(map_city, addmap)
             }
             map_city <- select(map_city, c(adcode, name_province, name_city, level))
             map_city <- rbind(map_city, dash_line1)
             #区县级地图
             # (1) 直辖市和特别行政区
             map_district0 <- map_city %>% filter(level == "district")
             map_district0$name_district <- map_district0$name_city
             map_district0$name_city <- NA
             map_district0 <- select(map_district0, c(adcode, name_province, name_city, name_district, level))
             #(2) 有区县的城市
             tmp <- map_city %>% filter(level == "city") %>% select(c(adcode, name_province, name_city))
             map_district <- c()
             for (i in 1:nrow(tmp)){
               url <- paste0("https://geo.datav.aliyun.com/areas_v2/bound/", tmp$adcode[i], "_full.json")
               addmap <- read_sf(url) %>% select(c(adcode, name, level))
               addmap$name_province <- tmp$name_province[i]
               addmap$name_city <- tmp$name_city[i]
               addmap$name_district <- addmap$name
               map_district <- rbind(map_district, addmap)
             }
             map_district <- select(map_district, c(adcode, name_province, name_city, name_district, level))
             map_district <- rbind(map_district0, map_district, taiwan2, dash_line2)
             map <- map_district
           },
           default = {
             map_province <- read_sf("https://geo.datav.aliyun.com/areas_v2/bound/100000_full.json") %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             map <- map_province
           }
    )
  } else if (substr(adcode, 3, 4) == "00" & substr(adcode, 1, 2) %in% c(11, 12, 31, 50, 81, 82) == F)  {
    switch(level,
           province = {
             map_province <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,".json")) %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             map <- map_province
           },
           city = {
             map_city <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,"_full.json")) %>% select(c(adcode, name, level))
             map_city <- rename(map_city, "name_city" = "name")
             map <- map_city
           },
           district = {
             map_city <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,"_full.json")) %>% select(c(adcode, name, level))
             map_city <- rename(map_city, "name_city" = "name")
             tmp <- map_city %>% filter(level == "city") %>% select(c(adcode, name_city))
             map_district <- c()
             for (i in 1:nrow(tmp)){
               url <- paste0("https://geo.datav.aliyun.com/areas_v2/bound/", tmp$adcode[i], "_full.json")
               addmap <- read_sf(url) %>% select(c(adcode, name, level))
               addmap$name_city <- tmp$name_city[i]
               addmap$name_district <- addmap$name
               map_district <- rbind(map_district, addmap)
             }
             map <- map_district
           },
           default = {
             map_city <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,"_full.json")) %>% select(c(adcode, name, level))
             map_city <- rename(map_city, "name_city" = "name")
             map <- map_city
           }
    )
  } else if (substr(adcode, 3, 4) == "00" & substr(adcode, 1, 2) %in% c(11, 12, 31, 50, 81, 82) == T) {
    switch(level,
           province = {
             map_province <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,".json")) %>% select(c(adcode, name, level))
             map_province <- rename(map_province, "name_province" = "name")
             map <- map_province},
           city = {
             message("The argument of level is not allowed for the municipality or special administrative region, please use 'level = district'.")
           },
           district = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,"_full.json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           },
           default = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,"_full.json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           }
    )
  }  else {
    switch(level,
           province = {
             message("Error argument of 'level'.")
           },
           city = {
             map_city <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,".json")) %>% select(c(adcode, name, level))
             map_city <- rename(map_city, "name_city" = "name")
             map <- map_city
           },
           district = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,"_full.json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           },
           default = {
             map_district <- read_sf(paste0("https://geo.datav.aliyun.com/areas_v2/bound/",adcode,"_full.json")) %>% select(c(adcode, name, level))
             map_district <- rename(map_district, "name_district" = "name")
             map <- map_district
           }
    )
  }

  return(map)
}

