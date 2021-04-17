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

###################
# 10,000 addresses
###################
dat <- data.frame(Number= 1:10000,
                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", 
                             "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))

system.time(z <- geocoord(dat$address))
#    user     system    elapsed                                         
#    2.813    0.968     62.649
```

When the number of addresses over 500, `geocoord` will use the parallel operation. Theoretically,  the more CPU cores you have, the faster you get the coordinates.




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

