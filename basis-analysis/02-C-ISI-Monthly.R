# Copyright Reserved

#####----Guidance----#####

library(tidyverse)
library(lubridate)
library(zoo)
library(cnquant)

load("~/Documents/Stock Data/D-Index-Daily-Data.RData")


#####----读取数据----#####

# 读取月度BW投资者情绪指标和指数数据
ISI_Monthly_Data <- read_tsv("./Data/raw-data/QX_ISI.txt", 
         col_names = c("统计月度", "上月封闭基金平均折价率", "IPO首日收益率均值", "IPO数", 
                       "新增开户数", "上月市场换手率", "上月消费者信心", "投资者情绪指数"), 
         col_types = "cddidddd", skip = 3) %>% 
  mutate(`统计月度` = month_end(as.Date(as.yearmon(`统计月度`)))) %>% 
  arrange(`统计月度`)

# PCA
ISI_Monthly_Data <- ISI_Monthly_Data %>% 
  prcomp(~ . - `统计月度` - `投资者情绪指数`, data = ., scale = TRUE) %>% 
  predict() %>% 
  as_tibble() %>% 
  bind_cols(ISI_Monthly_Data, .) %>% 
  select(`统计月度`, ISI = PC1) %>% 
  mutate(ISI = -ISI)

# 合并指数数据
ISI_Monthly_Data <- Index_Daily_Data %>% 
  filter(S_INFO_WINDCODE == "000001.SH") %>% 
  select(TRADE_DT, `上证指数` = S_DQ_CLOSE) %>% 
  group_by(substr(TRADE_DT, 1, 6)) %>% 
  slice(n()) %>% 
  ungroup() %>% 
  transmute(`统计月度` = month_end(ymd(TRADE_DT)), `上证指数`) %>% 
  left_join(ISI_Monthly_Data, .)

# 调整数据结构
ISI_Monthly_Data <- ISI_Monthly_Data %>% 
  mutate(ISI = round(ISI * 400, 2)) %>% 
  rename(`投资者情绪指数` = ISI) %>% 
  gather(`指数`, `指数取值`, -`统计月度`) %>% 
  mutate(`指数` = factor(`指数`, levels = c("投资者情绪指数", "上证指数")))

# 计算一些其它辅助数据

# ISI_Monthly vector
ISI_Monthly <- ISI_Monthly_Data %>% 
  filter(`指数` == "投资者情绪指数") %>% 
  pull(`指数取值`)

# 保存数据
save(ISI_Monthly_Data, ISI_Monthly, file = "./data/02-D-ISI-Monthly-Data.RData")
