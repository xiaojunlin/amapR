# amapR
An R package using AMap API to convert addresses into coordinates.

## Installation

```R
devtools::install_github("xiaojunlin/amapR") 
```

## geocoord

Before using the package, please make sure that you have applied the AMap Web Service API key from the [official website](https://lbs.amap.com/api/webservice/guide/create-project/get-key).

```R
library(amapR)
options(amap.key = 'xxxxxxxx')
```

Use the `geocoord` function to convert addresses into coordinates. Here is the [manual](docs/amapR_0.2.0.pdf) for this package.

![geocoord example](docs/geocoord_example.gif)


- When the number of addresses is less than or equal to 200, `geocoord` only utilizes one processor, which makes it single-threaded.

>200 addresses

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

- When the number of addresses is over 200, `geocoord` utilizes multiple processors and runs parallel computation. The following examples were run in the MacBook Pro (13-inch, 2016, Four Thunderbolt 3 Ports) with Intel Core i5 (2 cores and 4 threads).

>1,000 addresses

```R
test <- data.frame(n = 1:1000, address = c("华中科技大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user     system    elapsed
0.142    0.057     7.475 
```

>10,000 addresses

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

Here is the returned result in `data.table` format.

```R
result
```
```R
        n  address          formatted_address    longitude latitude
   1:    1 四川大学         四川省成都市武侯区四川大学  104.0837 30.63087
   2:    2 华中科技大学  湖北省武汉市洪山区华中科技大学  114.4345 30.51105
   3:    3 四川大学         四川省成都市武侯区四川大学  104.0837 30.63087
   4:    4 华中科技大学  湖北省武汉市洪山区华中科技大学  114.4345 30.51105
   5:    5 四川大学         四川省成都市武侯区四川大学  104.0837 30.63087
  ---                                                            
 996:  996 华中科技大学  湖北省武汉市洪山区华中科技大学  114.4345 30.51105
 997:  997 四川大学         四川省成都市武侯区四川大学  104.0837 30.63087
 998:  998 华中科技大学  湖北省武汉市洪山区华中科技大学  114.4345 30.51105
 999:  999 四川大学         四川省成都市武侯区四川大学  104.0837 30.63087
1000: 1000 华中科技大学  湖北省武汉市洪山区华中科技大学  114.4345 30.51105
```

- Theoratically, the more CPU cores you have, the faster the `geocoord` function will be. To compare the speed of `geocoord` function, we have queryed **100,000** addresses in the following two different platforms. The results shown that the Windows with more CPU cores is faster than the macOS (**260**s vs **629**s).

> **macOS**: 2.9GHz Intel Core i5 (2 cores and 4 threads) , 16 GB memory

```R
# 100,000 addresses
test <- data.frame(n = 1:100000, address = c("华中科技大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user     system    elapsed
9.964    2.996     628.518   
```

> **Windows**: 3.6GHz Intel Core i7 (4 cores and 8 threads), 8 GB mermory

```R
# 100,000 addresses
test <- data.frame(n = 1:100000, address = c("华中科技大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user     system    elapsed
4.93     0.58      260.27   
```
However, the Amap Web Service API have set the [query limit](https://lbs.amap.com/api/webservice/guide/tools/flowlevel) (e.g., 200 times per second for personal certified developer). For personal certified developer, I would not recommend you to use too many CPU cores. To avoid http error, you can set the specific number of CPU cores used in the `ncore` argument. For example:

> 2 CPU cores

```R
test <- data.frame(n = 1:3000, address = c("华中科技大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address", ncore = 2) )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user     system    elapsed
0.09     0.01      28.25 
```
> 4 CPU cores
```R
test <- data.frame(n = 1:3000, address = c("华中科技大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address", ncore = 4) )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user     system    elapsed
0.19     0.03      14.48 
```



### Benchmarking

[`amapGeocode`](https://cran.r-project.org/web/packages/amapGeocode/index.html) is a popular R package used to convert address into coordinates using AMap API.

We had queried a series of addresses using the `amapR` package and `amapGeocode` package, respectively. The results were shown below.

| Testing environment|  | 
| ------ | ------ | 
| Operation System | Windows | 
| CPU | 3.6GHz Intel Core i7 (4 cores and 8 threads) |
| Memory | 8 GB  |
| R version | 4.0.5 |
| RStudio version | 1.4.1106 |
| Network| China Telecom, Chengdu|
| Date |2021-04-20 8:00PM  (GMT+8) |F



![benchmarking](docs/benchmarking.png)


## geolocation

Convert the coordinates into formatted addresses.

For example:

> 200 coordinates

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

> 10,000 coordinates

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


## transcoord

Transform the coordinates from other coordinate systems to Amap system, including baidu, gps, and mapbar.

For example:

> 200 coordinates from gps system

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
> 10,000 coordinates from baidu system

```R
test <- data.frame(n = 1:10000, lng = c(114.4345,104.0837), lat = c(30.51105, 30.63087))
system.time( results <- transcoord(data = test, longitude = "lng", latitude = "lat", coordsys = "baidu") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user    system  elapsed 
0.593   0.202   32.925 
```
