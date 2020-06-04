# gaodemap
An R package for getting coordinates and locations via Gaode Map API

## Installation

```
if (!requireNamespace("devtools"))
  install.packages("devtools")
  
devtools::install_github("xiaojunlin/gaodemap") 
```

## Usage

Apply an application from https://lbs.amap.com/api/webservice/guide/create-project/get-key. Then register you key here.

```
library(gaodemap)
options(gaode.key = 'XXXXXXXXXXX')
```

### fetchCoordinate
Get longitude and latitude from a given address.

```
address = c('北京市朝阳区望京东路4号横店大厦','北京市海淀区上地信息路9号奎科科技大厦','aaa',NA)
coordinate <-fetchCoordinate(address)
```

### fetchLocation
Get address from the given coordinates.

```
data = data.frame(
      lat = c(39.934,40.013,40.047,NA,4444),
      lon = c(116.329,116.495,116.313,NA,6666)
    )

address <- fetchLocation(lon = data$lon, lat = data$lat)
address <- fetchLocation(lon = 104.0665, lat = 30.57227)
```

### fetchDistance
Calculate the travel distance between origins and destinations. Please note that the format of the origins or destinations should be "longitude, latitude".

```
data <- data.frame(
    origin = c("118.796877,32.060255", "114.3054,45.222", "114.777,33.123", "116.12223,35.333"),
    dest   = c("121.473701,31.230416", "122.44221,30.2223", "NA,NA", "99999,66666")
  )

dist <- fetchDistance(origin = data$origin, dest = data$dest, type = '0')
dist <- fetchDistance(origin = data$origin, dest = data$dest, type = '1')
dist <- fetchDistance(origin = data$origin, dest = c("118.796877, 34.1234"), type = '1')
```

## Acknowledgements

This `gaodemap` R package is developed based on the [R codes](https://zhuanlan.zhihu.com/p/108318434) posted by Yu Du. 

We modified his/her R codes by adding a progress bar to visualize the data fetching process clearly. We also make some changes on the function arguments and add the `fetchDsitance` function to calculate the travel distance between origins and destinations. 
