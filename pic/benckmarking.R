
library(amap)
options(amap.key = '023b7a9251e3b5a0eee9027acd9a4576')
library(amapGeocode)

#data generation process
dgp <- function(n) {
  address <- data.frame(Number= 1:n,
             address = c("北京大学", "清华大学", "武汉大学", "华中科技大学", "南京大学", "中山大学", "四川大学", "中国科学技术大学", "哈尔滨工业大学", "复旦大学"))
  return(address)
}

# benchmarking
amap_t1 <- system.time(z1 <- amap::fetchCoordinate(dgp(100)$address))
amapGeocode_t1 <- system.time(z2 <- amapGeocode::getCoord(dgp(100)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t2 <- system.time(z1 <- amap::fetchCoordinate(dgp(200)$address))
amapGeocode_t2 <- system.time(z2 <- amapGeocode::getCoord(dgp(200)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))

amap_t3<- system.time(z1 <- amap::fetchCoordinate(dgp(300)$address))
amapGeocode_t3 <- system.time(z2 <- amapGeocode::getCoord(dgp(300)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t4 <- system.time(z1 <- amap::fetchCoordinate(dgp(400)$address))
amapGeocode_t4 <- system.time(z2 <- amapGeocode::getCoord(dgp(400)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))

amap_t5 <- system.time(z1 <- amap::fetchCoordinate(dgp(500)$address))
amapGeocode_t5 <- system.time(z2 <- amapGeocode::getCoord(dgp(500)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))

amap_t6 <- system.time(z1 <- amap::fetchCoordinate(dgp(600)$address))
amapGeocode_t6 <- system.time(z2 <- amapGeocode::getCoord(dgp(600)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t7 <- system.time(z1 <- amap::fetchCoordinate(dgp(700)$address))
amapGeocode_t7 <- system.time(z2 <- amapGeocode::getCoord(dgp(700)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t8 <- system.time(z1 <- amap::fetchCoordinate(dgp(800)$address))
amapGeocode_t8 <- system.time(z2 <- amapGeocode::getCoord(dgp(800)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t9 <- system.time(z1 <- amap::fetchCoordinate(dgp(900)$address))
amapGeocode_t9 <- system.time(z2 <- amapGeocode::getCoord(dgp(900)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t10 <- system.time(z1 <- amap::fetchCoordinate(dgp(1000)$address))
amapGeocode_t10 <- system.time(z2 <- amapGeocode::getCoord(dgp(1000)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))

amap_t20 <- system.time(z1 <- amap::fetchCoordinate(dgp(2000)$address))
amapGeocode_t20 <- system.time(z2 <- amapGeocode::getCoord(dgp(2000)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t30 <- system.time(z1 <- amap::fetchCoordinate(dgp(3000)$address))
amapGeocode_t30 <- system.time(z2 <- amapGeocode::getCoord(dgp(3000)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t40 <- system.time(z1 <- amap::fetchCoordinate(dgp(4000)$address))
amapGeocode_t40 <- system.time(z2 <- amapGeocode::getCoord(dgp(4000)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t50 <- system.time(z1 <- amap::fetchCoordinate(dgp(5000)$address))
amapGeocode_t50 <- system.time(z2 <- amapGeocode::getCoord(dgp(5000)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


amap_t100 <- system.time(z1 <- amap::fetchCoordinate(dgp(10000)$address))
amapGeocode_t100 <- system.time(z2 <- amapGeocode::getCoord(dgp(10000)$address, key = '023b7a9251e3b5a0eee9027acd9a4576'))


# Results
benchmarking <- data.frame(n = c(100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 10000),
                           amap = c(amap_t1[3], amap_t2[3], amap_t3[3], amap_t4[3], amap_t5[3], amap_t6[3], amap_t7[3],amap_t8[3], amap_t9[3], amap_t10[3], amap_t20[3], amap_t30[3],  amap_t40[3], amap_t50[3], amap_t100[3]),
                           amapGeocode = c(amapGeocode_t1[3], amapGeocode_t2[3], amapGeocode_t3[3], amapGeocode_t4[3], amapGeocode_t5[3], amapGeocode_t6[3], amapGeocode_t7[3], amapGeocode_t8[3], amapGeocode_t9[3], amapGeocode_t10[3], amapGeocode_t20[3], amapGeocode_t30[3], amapGeocode_t40[3], amapGeocode_t50[3], amapGeocode_t100[3])) %>%
  sjmisc::reshape_longer(
  columns = c("amap", "amapGeocode"),
  names.to = "packagename",
  values.to = "time"
) %>% mutate(speed = round(n/time, 0))

# plot
library(tidyverse)
ggplot(benchmarking) +
  geom_line(aes(x= .id, y = time, group = packagename, col = packagename)) +
  geom_point(aes(x= .id, y = time, group = packagename, col = packagename)) +
  scale_x_continuous (breaks=seq(1, 15, 1),
    labels = c("100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "2000", "3000", "4000", "5000", "10000")) +
  theme_bw() +
  xlab("Number of address") +
  ylab("Time (second)") +
  theme(legend.title=element_blank())

# save plot
ggsave("/Users/kevinlin/Dropbox/GitHub/amap/pic/benckmarking.png")
