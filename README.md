# amap
An R package using AMap API.

## Installation

```R
if (!requireNamespace("devtools"))
  install.packages("devtools")
  
devtools::install_github("xiaojunlin/amap") 
```

## Usage

Before using the package, please apply your key from the [AMap](https://lbs.amap.com/api/webservice/guide/create-project/get-key).

```R
library(amap)
options(amap.key = 'XXXXXXXXXXX')
```

### fetchMap

Using the [administrative code](http://www.mca.gov.cn/article/sj/xzqh/2020/), we can fetch data and map at province, city or district level. The map data is fetched using the JSON API of [DATAV.GeoAtlas](https://datav.aliyun.com/tools/atlas/).

#### (1) China Map

```R
# China map
# (1) fetch and map at province level
china1 <- fetchMap(adcode = 100000, level = "province")
ggplot(china1) +
 geom_sf(fill = "white") +
 theme_bw()
# (2) fetch and map at city level
china2 <- fetchMap(adcode = 100000,  level = "city")
ggplot(china2) +
 geom_sf(fill = "white") +
 theme_bw()
# (3) fetch and map at district level
china3 <- fetchMap(adcode = 100000,  level = "district")
ggplot(china3) +
  geom_sf(fill = "white") +
  theme_bw()
# (4) fetch and map with missing value in the argment "level"
sichuan4 <- fetchMap(adcode = 100000)
ggplot(china4) +
  geom_sf(fill = "white") +
  theme_bw()
```

<center class="half">    <img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_china_prov.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_china_city.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_china_district.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_china_missing.png" width="300"/> </center>





#### (2) Sichuan Map

```R
# (1) fetch and map at province level
sichuan1 <- fetchMap(adcode = 510000, level = "province")
ggplot(sichuan1) +
  geom_sf(fill = "white") +
  theme_bw()
# (2) fetch and map at city level
sichuan2 <- fetchMap(adcode = 510000, level = "city")
ggplot(sichuan2) +
  geom_sf(fill = "white") +
  theme_bw()
# (3) fetch and map at district level
sichuan3 <- fetchMap(adcode = 510000, level = "district")
ggplot(sichuan3) +
  geom_sf(fill = "white") +
  theme_bw()
# (4) fetch and map with missing value in the argment "level"
sichuan4 <- fetchMap(adcode = 510000)
ggplot(sichuan4) +
  geom_sf(fill = "white") +
  theme_bw()
```

<center class="half">    <img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_sc_prov.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_sc_city.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_sc_district.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_sc_missing.png" width="300"/> </center>



#### (3) Chengdu Map

```R
# City map
# (1) fetch and map at city level
chengdu1 <- fetchMap(adcode = 510100, level = "city")
ggplot(chengdu1) +
  geom_sf(fill = "white") +
  theme_bw()
# (2) fetch and map at district level
chengdu2 <- fetchMap(adcode = 510100, level = "district")
ggplot(chengdu2) +
  geom_sf(fill = "white") +
  theme_bw()
# (3) fetch and map with missing value in the argment "level"
chengdu3 <- fetchMap(adcode = 510100)
ggplot(chengdu3) +
  geom_sf(fill = "white") +
  theme_bw()
```

<center class="half">    <img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_cd_city.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_cd_district.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_cd_missing.png" width="300"/> </center>



### fetchCoordinate

Get the coordinates (longitude and latitude) from the given addresses.

```R
###########
# 1 address
###########
fetchCoordinate("四川大学")

###############
# 500 addresses
###############
x <- data.frame(Number= 1:500,
                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))

system.time(z <- fetchCoordinate(x$address))
#   user   system   elapsed                                                                                                         
#   1.389  0.100    9.125  

###################
# 20,000 addresses
###################
x <- data.frame(Number= 1:20000,
                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))

system.time(z <- fetchCoordinate(x$address))
#    user     system    elapsed                                         
#    51.156   3.293     360.325 
```

### fetchLocation
Get the addresses from the given coordinates.

```R
coordinate = data.frame(
      lat = c(39.934,40.013,40.047,NA,4444),
      lon = c(116.329,116.495,116.313,NA,6666)
    )

address <- fetchLocation(lon = coordinate$lon, lat = coordinate$lat)
address <- fetchLocation(lon = 104.0665, lat = 30.57227)
```

### fetchDistance
Calculate the travel distance and travel time between origins and destinations. There are three travel ways, including the straight line distancee (type = 0), driving (type = 1) and walking (type = 2). The returned results are travel distance (unit: meter) and travel time (unit: second, only for driving and walking).

```R
x <- data.frame(
  a = c(104.0141, 104.0518, 104.0644, 104.0390, 104.1890,  NA),
  b = c(30.66794, 30.64201, 30.64035, 30.66362, 30.65145,  NA),
  c = c(104.0652, 104.0652, 104.0652, 104.0652, 104.0652,  104.0652),
  d = c(30.57851, 30.57851, 30.57851, 30.57851, 30.57851,  30.57851)
  )

y <- fetchDistance(data = x, lon1 = "a" , lat1 = "b", lon2 = "c", lat2 ="d", type = 0)
z <- fetchDistance(data = x, lon1 = "a" , lat1 = "b", lon2 = "c", lat2 ="d", type = 1)
```
