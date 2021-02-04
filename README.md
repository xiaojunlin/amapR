# amap
An R package using AMap API.

## Installation

```R
if (!requireNamespace("devtools")) install.packages("devtools")
devtools::install_github("xiaojunlin/amap") 
```

## Usage

Before using the package, please apply your key from the [AMap](https://lbs.amap.com/api/webservice/guide/create-project/get-key).

```R
library(amap)
options(amap.key = 'XXXXXXXXXXX')
```

### geocoord

Get the coordinates (longitude and latitude) from the given addresses.

```R
###########
# 1 address
###########
geocoord("四川大学")

###############
# 500 addresses
###############
dat <- data.frame(Number= 1:500,
                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", 
                             "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))

# query 10 addresses per batch (up to the query limit in each batch)
system.time(z <- geocoord(dat$address)) # n = 10 by default
#   user   system   elapsed                                                                                                         
#   1.389  0.100    9.125

# query less addresses per batch (slower but more stable)
system.time(z <- geocoord(dat$address, n = 5)) 
#   user   system   elapsed 
#   2.560  0.227    18.502
```

When the number of addresses over 600, `geocoord` will use the parallel operation. A progress bar is presented using the `pbapply` package. Theoretically,  the more CPU cores you have, the faster you get the coordinates.

Here is a MacBook Pro with 4 cores:

> MacBook Pro (13-inch, 2016, Four Thunderbolt 3 Ports)
> CPU: Intel Core i5 @ 2.9GHz (4 cores)
> RAM: 16GB RAM
> OS: macOS Big Sur 11.1

```R
###################
# 10,000 addresses
###################
dat <- data.frame(Number= 1:10000,
                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", 
                             "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))

system.time(z <- geocoord(dat$address))
#    user     system    elapsed                                         
#    2.813    0.968     62.649

###################
# 20,000 addresses
###################
dat <- data.frame(Number= 1:20000,
                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", 
                             "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))

system.time(z <- geocoord(dat$address))
#    user     system    elapsed                                         
#    3.230    1.176     106.612 
```

Here is a Windows PC with 8-core CPU: 

> CPU: Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz   3.60 GHz (8 cores)
> RAM: 8.00 GB
> OS: Windows 10 Professional (20H2)

```R
###################
# 20,000 addresses
###################
dat <- data.frame(Number= 1:20000,
                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", 
                             "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))

system.time(z <- geocoord(dat$address))
#    user     system    elapsed                                         
#    1.95     1.37      68.70
```

### geolocation

Get the addresses from the given coordinates.

```R
coordinate = data.frame(
      lat = c(39.934,40.013,40.047,NA,4444),
      lon = c(116.329,116.495,116.313,NA,6666)
    )

address <- geolocation(lon = coordinate$lon, lat = coordinate$lat)
address <- geolocation(lon = 104.0665, lat = 30.57227)
```

### geodist
Calculate the travel distance and travel time between origins and destinations. There are three travel ways, including the straight line distancee (type = 0), driving (type = 1) and walking (type = 2). The returned results are travel distance (unit: meter) and travel time (unit: second, only for driving and walking).

```R
x <- data.frame(
  a = c(104.0141, 104.0518, 104.0644, 104.0390, 104.1890,  NA),
  b = c(30.66794, 30.64201, 30.64035, 30.66362, 30.65145,  NA),
  c = c(104.0652, 104.0652, 104.0652, 104.0652, 104.0652,  104.0652),
  d = c(30.57851, 30.57851, 30.57851, 30.57851, 30.57851,  30.57851)
  )

y <- geodist(data = x, lon1 = "a" , lat1 = "b", lon2 = "c", lat2 ="d", type = 0)
z <- geodist(data = x, lon1 = "a" , lat1 = "b", lon2 = "c", lat2 ="d", type = 1)
```

### geomap

Using the [administrative code](http://www.mca.gov.cn/article/sj/xzqh/2020/), we can fetch data and map at province, city or district level. The map data is fetched using the JSON API of [DATAV.GeoAtlas](https://datav.aliyun.com/tools/atlas/).

- China Map

```R
# China map
# (1) map at province level
china1 <- geomap(adcode = 100000, level = "province")
ggplot(china1) +
 geom_sf(fill = "white") +
 theme_bw()
# (2) map at city level
china2 <- geomap(adcode = 100000,  level = "city")
ggplot(china2) +
 geom_sf(fill = "white") +
 theme_bw()
# (3) map at district level
china3 <- geomap(adcode = 100000,  level = "district")
ggplot(china3) +
  geom_sf(fill = "white") +
  theme_bw()
# (4) map with missing value in the argment "level"
sichuan4 <- geomap(adcode = 100000)
ggplot(china4) +
  geom_sf(fill = "white") +
  theme_bw()
```

<center class="half">    <img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_china_prov.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_china_city.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_china_district.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_china_missing.png" width="300"/> </center>

- Sichuan Map

```R
# (1) map at province level
sichuan1 <- geomap(adcode = 510000, level = "province")
ggplot(sichuan1) +
  geom_sf(fill = "white") +
  theme_bw()
# (2) map at city level
sichuan2 <- geomap(adcode = 510000, level = "city")
ggplot(sichuan2) +
  geom_sf(fill = "white") +
  theme_bw()
# (3) map at district level
sichuan3 <- geomap(adcode = 510000, level = "district")
ggplot(sichuan3) +
  geom_sf(fill = "white") +
  theme_bw()
# (4) map with missing value in the argment "level"
sichuan4 <- geomap(adcode = 510000)
ggplot(sichuan4) +
  geom_sf(fill = "white") +
  theme_bw()
```

<center class="half">    <img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_sc_prov.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_sc_city.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_sc_district.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_sc_missing.png" width="300"/> </center>

- Chengdu Map

```R
# City map
# (1) map at city level
chengdu1 <- geomap(adcode = 510100, level = "city")
ggplot(chengdu1) +
  geom_sf(fill = "white") +
  theme_bw()
# (2) map at district level
chengdu2 <- geomap(adcode = 510100, level = "district")
ggplot(chengdu2) +
  geom_sf(fill = "white") +
  theme_bw()
# (3) map with missing value in the argment "level"
chengdu3 <- geomap(adcode = 510100)
ggplot(chengdu3) +
  geom_sf(fill = "white") +
  theme_bw()
```

<center class="half">    <img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_cd_city.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_cd_district.png" width="300"/><img src="https://github.com/xiaojunlin/amap/raw/master/pic/map_cd_missing.png" width="300"/> </center>

