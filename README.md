# gaodemap
An R package for getting coordinates and locations using Gaode Map API

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
Get longtitude and latitude from a given address.

```
testaddress = c('北京市朝阳区望京东路4号横店大厦','北京市海淀区上地信息路9号奎科科技大厦','aaa',NA)
coordinate <-fetchCoordinate(testaddress)
```

### fetchLocation
Get address from the given longtitude and latitude.

```
testdata = data.frame(
    lat = c(39.934,40.013,40.047,NA,4444),
    lon = c(116.329,116.495,116.313,NA,6666)
    )
address <- fetchLocation(testdata, lon = 'lon', lat = 'lat')
```

## Acknowledgements

This `gaodemap` R package is developed based on [the codes](https://zhuanlan.zhihu.com/p/108318434) posted by Yu Du. We thank Yu Du for sharing. 

We modified his codes by adding a progress bar to visualize the data fetching process clearly and make some changes on the function arguments.
