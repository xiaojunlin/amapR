# amapR
An R package using [AMap Web Service API](https://lbs.amap.com/api/webservice/guide/api/georegeo). 

Now, this packge has four functions: 
- `geocoord`: convert addresses into coordinates
- `geolocation`: convert coordinates into addresses
- `transcoord`: Transform the coordinates from other coordinate systems to amap coordinate system
- `getmap`: get the map data at province, city, or district level

**Latest Version: 0.2.7**

[**Manual**](https://github.com/xiaojunlin/amapR/raw/master/docs/amapR_0.2.7.pdf)

## Package features

- **Parallel computing**
  
  Under the premise of not exceeding the query limit, the more CPU cores you use, the faster the functions in this package will be.

- **Batch query**

   This package embeds the batch query feature of AMap Web Service API, which allows us to query a batch of addresses or coordinates in one time. For example, AMap API can convert 10 addresses into coordinates in one query. The upper query limit for personal certified developer is 3 million per day. That is, a developer with personal certification, theoratically, can convert <u>30 million</u> addresses per day.

- **Progress bar**
  
  This package provides a progress bar to show the query progress, which is very useful when the query time may be unpredictable.
  


## Installation

```R
devtools::install_github("xiaojunlin/amapR") 
```

**Notes:** 
- Before using the package, please make sure that you have applied the AMap Web Service API key from the [official website](https://lbs.amap.com/api/webservice/guide/create-project/get-key).
- set the amap.key options:
```R
library(amapR)
options(amap.key = 'xxxxxxxx')
```
## Usage
### geocoord
> convert addresses into coordinates




![geocoord example](docs/geocoord_example.gif)


When the number of addresses is less than or equal to 200, `geocoord` only utilizes one processor, which makes it single-threaded.

- 200 addresses

```R
test <- data.frame(n = 1:200, address = c("华中科技大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%  
user     system    elapsed
0.690    0.045     10.736
```
Here is the returned result in `data.table` format.

```R
result
```
```R
       n   address          formatted_address longitude latitude
  1:   1  华中科技大学 湖北省武汉市洪山区华中科技大学  114.4345 30.51105
  2:   2     四川大学     四川省成都市武侯区四川大学  104.0837 30.63087
  3:   3 华中科技大学 湖北省武汉市洪山区华中科技大学  114.4345 30.51105
  4:   4     四川大学     四川省成都市武侯区四川大学  104.0837 30.63087
  5:   5 华中科技大学 湖北省武汉市洪山区华中科技大学  114.4345 30.51105
 ---                                                                   
196: 196     四川大学     四川省成都市武侯区四川大学  104.0837 30.63087
197: 197 华中科技大学 湖北省武汉市洪山区华中科技大学  114.4345 30.51105
198: 198     四川大学     四川省成都市武侯区四川大学  104.0837 30.63087
199: 199 华中科技大学 湖北省武汉市洪山区华中科技大学  114.4345 30.51105
200: 200     四川大学     四川省成都市武侯区四川大学  104.0837 30.63087
```

When the number of addresses is over 200, `geocoord` utilizes multiple processors and parallel computation. The following examples were run in the MacBook Pro (13-inch, 2016, Four Thunderbolt 3 Ports) with Intel Core i5 (2 cores, 4 threads).

- 10,000 addresses

```R
# 10,000 addresses
test <- data.frame(n = 1:10000, address = c("华中科技大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user     system    elapsed
1.044    0.344     64.697   
```


### geolocation

>Convert the coordinates into formatted addresses.

Examples:

- 200 coordinates

```R
test <- data.frame(n = 1:200, lng = c(114.4345,104.0837), lat = c(30.51105, 30.63087))
system.time( results <- geolocation(data = test, longitude = "lng", latitude = "lat") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user    system  elapsed 
0.342   0.029   5.891 
```

- 10,000 coordinates

```R
test <- data.frame(n = 1:10000, lng = c(114.4345,104.0837), lat = c(30.51105, 30.63087))
system.time( results <- geolocation(data = test, longitude = "lng", latitude = "lat") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user    system  elapsed 
0.604   0.224   40.198 
```


### transcoord
>Transform the coordinates from other coordinate systems to Amap system, including baidu, gps, and mapbar.

Examples:

- 200 coordinates from gps system

```R
test <- data.frame(n = 1:200, lng = c(114.4345,104.0837), lat = c(30.51105, 30.63087))
results <- transcoord(data = test, longitude = "lng", latitude = "lat", coordsys = "gps")
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user    system  elapsed 
0.110   0.013   2.337 
```
- 10,000 coordinates from baidu system

```R
test <- data.frame(n = 1:10000, lng = c(114.4345,104.0837), lat = c(30.51105, 30.63087))
system.time( results <- transcoord(data = test, longitude = "lng", latitude = "lat", coordsys = "baidu") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user    system  elapsed 
0.316   0.108   16.892 
```


### getmap

> Get the map data at province, city, or district level.

You can get the administrative division codes in the [city lists](https://lbs.amap.com/api/webservice/download) provided by Amap.

Examples:

- China Map

```R
library(ggplot2)
library(amapR)

map <- getmap(adcode = 100000, level = "province")
ggplot(map) +
  geom_sf(fill = "white") +
  theme_bw()

map <- getmap(adcode = 100000, level = "city")
ggplot(map) +
  geom_sf(fill = "white") +
  theme_bw()

map <- getmap(adcode = 100000, level = "district")
ggplot(map) +
  geom_sf(fill = "white") +
  theme_bw()
```

- Sichuan Map

```R
library(ggplot2)
library(amapR)

map <- getmap(adcode = 510000, level = "province")
ggplot(map) +
  geom_sf(fill = "white") +
  theme_bw()

map <- getmap(adcode = 510000, level = "city")
ggplot(map) +
  geom_sf(fill = "white") +
  theme_bw()

map <- getmap(adcode = 510000, level = "district")
ggplot(map) +
  geom_sf(fill = "white") +
  theme_bw()
```

## References
[1] [Amap Webservices API](https://lbs.amap.com/api/webservice/summary)

[2] [DATAV.GeoAtlas](https://datav.aliyun.com/tools/atlas/index.html#&lat=10.14193168613103&lng=166.46484375&zoom=2)