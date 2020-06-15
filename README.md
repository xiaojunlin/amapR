# gaodemap
An R package for getting coordinates and locations via Gaode Map API

## Installation

```R
if (!requireNamespace("devtools"))
  install.packages("devtools")
  
devtools::install_github("xiaojunlin/gaodemap") 
```

## Usage

Apply an application from https://lbs.amap.com/api/webservice/guide/create-project/get-key. Then register you key here.

```R
library(gaodemap)
options(gaode.key = 'XXXXXXXXXXX')
```

### fetchCoordinate
Get longitude and latitude from a given address.

```R
x <- data.frame(Number= 1:500,
                 address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))

system.time(z <- fetchCoordinate(x$address))

fetchCoordinate("四川大学")
```

### fetchLocation
Get address from the given coordinates.

```R
coordinate = data.frame(
      lat = c(39.934,40.013,40.047,NA,4444),
      lon = c(116.329,116.495,116.313,NA,6666)
    )

address <- fetchLocation(lon = coordinate$lon, lat = coordinate$lat)
address <- fetchLocation(lon = 104.0665, lat = 30.57227)
```

### fetchDistance
Calculate the travel distance between origins and destinations. There are three travel ways supported, including direct line (type = 0), drive (type = 1) and walk (type = 2).

```R
x <- data.frame(
  a = c(104.0141, 104.0518, 104.0644, 104.0390, 104.1890,  NA),
  b = c(30.66794, 30.64201, 30.64035, 30.66362, 30.65145,  NA),
  c = c(104.0652, 104.0652, 104.0652, 104.0652, 104.0652,  104.0652),
  d = c(30.57851, 30.57851, 30.57851, 30.57851, 30.57851,  30.57851)
  )

y <- fetchDistance2(data = x, lon1 = "a" , lat1 = "b", lon2 = "c", lat2 ="d", type = 0)
z <- fetchDistance2(data = x, lon1 = "a" , lat1 = "b", lon2 = "c", lat2 ="d", type = 1)
```

## Acknowledgements

This `gaodemap` R package is inspired by the [R codes](https://zhuanlan.zhihu.com/p/108318434) posted by Yu Du. 

We have made some changes on the function arguments and add the `fetchDsitance` function to calculate the travel distance between origins and destinations. 
