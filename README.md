# amap
An R package using AMap API to convert addresses into coordinates.

## Installation

```R
devtools::install_github("xiaojunlin/amap") 
```

## Usage

Before using the package, please make sure that you have applied the AMap API key from the [official website](https://lbs.amap.com/api/webservice/guide/create-project/get-key).

```R
library(amap)
options(amap.key = 'xxxxxxxx')
```

### geocoord

Use the `geocoord` function to convert addresses into coordinates.

- When the number of addresses is less than or equal to 200, `geocoord` only utilizes one processor, which makes it single-threaded.

```R
test <- data.frame(n = 1:200, address = c("北京大学", "四川大学"))
system.time( results <- geocoord(data = test, address = "address") )
```
```R
[++++++++++++++++++++++++++++++++++++++++++] 100% elapsed=11s remaining~ 0s
Success rate:100%  |  Failure rate:0%  
user     system    elapsed
0.726    0.076     11.474
```

- When the number of addresses is over 200, `geocoord` utilizes multiple processors and runs parallel computation.

```R
# 1,000 addresses
test <- data.frame(n = 1:1000, address = c("北京大学", "四川大学"))
system.time( results <- geocoord(data = test, address = "address") )
```
```R
|++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=08s, remaining~00s
Success rate:100% | Failure rate:0%
user     system    elapsed
0.195    0.074     8.873 
```

```R
# 10,000 addresses
test <- data.frame(n = 1:10000, address = c("北京大学", "四川大学"))
system.time( results <- geocoord(data = test, address = "address") )
```
```R
|++++++++++++++++++++++++++++++++++++++++++| 100% elapsed=01m 08s, remaining~00s
Success rate:100% | Failure rate:0%
user     system    elapsed
1.877    0.612     68.592  
```
