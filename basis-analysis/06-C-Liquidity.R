library(tidyverse)

load("./data/raw-data/PIS-Data.RData")
load("~/Documents/Stock Data/D-Index-Daily-Data.RData")

# 生成日度市场流动性指数数据
Liquidity_Daily_Data <- PIS_Long %>% 
  rename(TRADE_DT = date) %>% 
  mutate(TRADE_DT = as.character(TRADE_DT)) %>% 
  group_by(TRADE_DT) %>% 
  summarise(PIS = mean(PIS))

# 合并指数数据
Liquidity_Daily_Data <- Index_Daily_Data %>% 
  filter(S_INFO_WINDCODE == "000001.SH") %>% 
  select(TRADE_DT, S_DQ_CLOSE) %>% 
  left_join(Liquidity_Daily_Data, .)

# 调整数据结构
Liquidity_Daily_Data <- Liquidity_Daily_Data %>% 
  mutate(TRADE_DT = ymd(TRADE_DT), 
         PIS = round(PIS * 2000, 2)) %>% 
  rename(`交易日期` = TRADE_DT, 
         `市场流动性指数` = PIS, 
         `上证指数` = S_DQ_CLOSE) %>% 
  gather(`指数`, `指数取值`, -`交易日期`) %>% 
  mutate(`指数` = factor(`指数`, levels = c("市场流动性指数", "上证指数")))

# 计算一些其它辅助数据

# Liquidity_Daily vector
Liquidity_Daily <- Liquidity_Daily_Data %>% 
  filter(`指数` == "市场流动性指数") %>% 
  pull(`指数取值`)

# 保存数据
save(Liquidity_Daily_Data, Liquidity_Daily, file = "./data/06-D-Liquidity-Daily-Data.RData")
