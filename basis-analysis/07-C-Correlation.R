library(tidyverse)

load("~/Documents/Stock Data/D-Index-Daily-Data.RData")

# 读取原始股票间交互强度数据
Correlation_Daily_Data <- read_csv("./data/raw-data/股票间交互强度指标.csv") %>% 
  select(TRADE_DT = date, COR = Indicator.7.days) %>% 
  mutate(TRADE_DT = format(TRADE_DT, "%Y%m%d"))

# 合并指数数据
Correlation_Daily_Data <- Index_Daily_Data %>% 
  filter(S_INFO_WINDCODE == "000001.SH") %>% 
  select(TRADE_DT, S_DQ_CLOSE) %>% 
  left_join(Correlation_Daily_Data, .)

# 调整数据结构
Correlation_Daily_Data <- Correlation_Daily_Data %>% 
  mutate(TRADE_DT = ymd(TRADE_DT), 
         COR = round(COR * 1000, 2)) %>% 
  rename(`交易日期` = TRADE_DT, 
         `股票间交互强度指数` = COR, 
         `上证指数` = S_DQ_CLOSE) %>% 
  gather(`指数`, `指数取值`, -`交易日期`) %>% 
  mutate(`指数` = factor(`指数`, levels = c("股票间交互强度指数", "上证指数")))

# 计算一些其它辅助数据

# Correlation_Daily vector
Correlation_Daily <- Correlation_Daily_Data %>% 
  filter(`指数` == "股票间交互强度指数") %>% 
  pull(`指数取值`)

# 保存数据
save(Correlation_Daily_Data, Correlation_Daily, file = "./data/07-D-Correlation-Daily-Data.RData")
