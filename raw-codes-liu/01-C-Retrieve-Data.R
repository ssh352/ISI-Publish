# Copyright Reserved

#####----Guidance----#####

library(tidyverse)
library(cnquant)


#####----读取数据----#####

conn <- wind_sql_connect()

Stock_Moneyflow <- conn %>% 
  tbl("AshareMoneyflow") %>% 
  select(S_INFO_WINDCODE, 
         TRADE_DT, 
         BUY_VALUE_SMALL_ORDER, 
         SELL_VALUE_SMALL_ORDER, 
         BUY_VALUE_EXLARGE_ORDER, 
         SELL_VALUE_EXLARGE_ORDER, 
         BUY_TRADES_EXLARGE_ORDER, 
         SELL_TRADES_EXLARGE_ORDER, 
         BUY_TRADES_SMALL_ORDER, 
         SELL_TRADES_SMALL_ORDER) %>% 
  collect()

Stock_L2_Indicators <- conn %>% 
  tbl("AShareL2Indicators") %>% 
  select(S_INFO_WINDCODE, 
         TRADE_DT)

save(Stock_Moneyflow, file = "./Data/Stock-Moneyflow.RData")


#####---- 读取CSMAR数据 ----#####

