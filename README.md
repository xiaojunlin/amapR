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

>200 addresses

```R
test <- data.frame(n = 1:200, address = c("北京大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%  
user     system    elapsed
0.690    0.045     10.736
```

- When the number of addresses is over 200, `geocoord` utilizes multiple processors and runs parallel computation.

>1,000 addresses

```R
test <- data.frame(n = 1:1000, address = c("北京大学", "四川大学"))
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
test <- data.frame(n = 1:10000, address = c("北京大学", "四川大学"))
system.time( result <- geocoord(data = test, address = "address") )
```
```R
|::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::| 100%
Success rate:100% | Failure rate:0%
user     system    elapsed
1.044    0.344     64.697   
```

Here is the result.

```R
results
```
```R
        n  address          formatted_address longitude latitude
   1:    1 四川大学 四川省成都市武侯区四川大学  104.0837 30.63087
   2:    2 北京大学       北京市海淀区北京大学  116.3083 39.99530
   3:    3 四川大学 四川省成都市武侯区四川大学  104.0837 30.63087
   4:    4 北京大学       北京市海淀区北京大学  116.3083 39.99530
   5:    5 四川大学 四川省成都市武侯区四川大学  104.0837 30.63087
  ---                                                            
 996:  996 北京大学       北京市海淀区北京大学  116.3083 39.99530
 997:  997 四川大学 四川省成都市武侯区四川大学  104.0837 30.63087
 998:  998 北京大学       北京市海淀区北京大学  116.3083 39.99530
 999:  999 四川大学 四川省成都市武侯区四川大学  104.0837 30.63087
1000: 1000 北京大学       北京市海淀区北京大学  116.3083 39.99530
```

