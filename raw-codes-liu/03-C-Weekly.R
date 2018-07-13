# Copyright Reserved

#####----Guidance----#####

library(tidyverse)
library(lubridate)
library(cnquant)
library(PerformanceAnalytics)

load("~/Documents/Stock Data/D-Stock-Daily-Data.RData")
load("~/Documents/Stock Data/D-Stock-Daily-Moneyflow-tmp.RData")
load("~/Documents/Stock Data/D-Stock-Daily-L2-Indicators-tmp.RData")
load("~/Documents/Stock Data/D-Index-Daily-Data.RData")


#####----投资者情绪指标----#####

# Join data
Stock_Daily_Data <- Stock_Daily_Data %>% 
  left_join(Stock_Daily_Moneyflow) %>% 
  left_join(Stock_Daily_L2_Indicators)

# Wind SQL中计算得到的
IS_Factor_Daily_Data <- Stock_Daily_Data %>% 
  mutate(RSSP = BUY_TRADES_SMALL_ORDER / SELL_TRADES_SMALL_ORDER, 
         PSD = (BUY_VALUE_SMALL_ORDER + SELL_VALUE_SMALL_ORDER) * 10 / 2 / S_DQ_AMOUNT, 
         RLSP = BUY_TRADES_EXLARGE_ORDER / SELL_TRADES_EXLARGE_ORDER, 
         PLD = (BUY_VALUE_EXLARGE_ORDER + SELL_VALUE_EXLARGE_ORDER) * 10 / 2 / S_DQ_AMOUNT) %>% 
  group_by(TRADE_DT) %>% 
  summarise(TURN = weighted_mean(S_DQ_FREETURNOVER, S_DQ_MV), 
            ADVR = sum(S_DQ_AMOUNT[S_DQ_PCTCHANGE > 0]) / sum(S_DQ_AMOUNT[S_DQ_PCTCHANGE < 0]), 
            ADL = sum(S_DQ_PCTCHANGE > 0) / sum(S_DQ_PCTCHANGE < 0), 
            ARMS = ADL / ADVR, 
            HI2LO = sum(S_DQ_HIGH >= S_PQ_HIGH_52W_) / sum(S_DQ_LOW <= S_PQ_LOW_52W_), 
            PCTHI = sum(S_DQ_HIGH >= S_PQ_HIGH_52W_) / n(),   # 理论上应该最多相等，实际上有4个大于的点，形如14.5 vs 14.499
            PCTLO = sum(S_DQ_LOW <= S_PQ_LOW_52W_) / n(), 
            RSSP = weighted_mean(RSSP, S_DQ_MV), 
            PSD = weighted_mean(PSD, S_DQ_MV), 
            RLSP = weighted_mean(RLSP, S_DQ_MV), 
            PLD = weighted_mean(PLD, S_DQ_MV), 
            BAR = weighted_mean(S_LI_ENTRUSTRATE, S_DQ_MV))

# 加入CSMAR中计算得到的
# ! QX_FundDiscountPremium是即时更新的
IS_Factor_Daily_Data <- read_csmar_data("~/Documents/Stock Data/CSMAR/基金折溢价率表142319814/QX_FundDiscountPremium.xls", 
                                        col_types = c(rep("guess", 12), "numeric")) %>% 
  filter(FundTypeID == "S0502") %>% 
  transmute(TRADE_DT = TradingDate %>% ymd() %>% format("%Y%m%d"), 
            CEFD = (NAV - ClosePrice) / ClosePrice) %>% 
  group_by(TRADE_DT) %>% 
  summarise(CEFD = mean(CEFD)) %>% 
  ungroup() %>% 
  left_join(IS_Factor_Daily_Data, .)

QX_Investor_Stop <- read_csmar_data("~/Documents/Stock Data/CSMAR/投资者情况统计表(停更)141126168/QX_InvestorStop.xls") %>% 
  filter(Datasgn == 3) %>% 
  transmute(TRADE_DT = EndDate %>% ymd() %>% format("%Y%m%d"), 
            PNI = NewAccounts * 2 / 3 / 10000 / FinalActiveAccounts) %>% 
  filter(TRADE_DT < "20150508")

IS_Factor_Daily_Data <- read_csmar_data("~/Documents/Stock Data/CSMAR/投资者情况统计表141334244/QX_Investor.xls") %>% 
  transmute(TRADE_DT = EndDate %>% ymd() %>% format("%Y%m%d"), 
            PNI = NewInvestors / FinalInvestors) %>% 
  bind_rows(QX_Investor_Stop, .) %>% 
  left_join(IS_Factor_Daily_Data, .) %>% 
  mutate_at(vars(CEFD, PNI), zoo::na.locf, na.rm = FALSE, fromLast = TRUE, maxgap = 5)

save(IS_Factor_Daily_Data, file = "./data/IS-Factor-Daily-Data.RData")


#####----指标分析----#####

# Winsorize
IS_Factor_Daily_Data <- IS_Factor_Daily_Data %>% 
  mutate_at(vars(-TRADE_DT), winsorize)

# summary statistics
IS_Factor_Daily_Data %>% 
  select(-TRADE_DT) %>% 
  sapply(summ_stats)

# correlation
IS_Factor_Daily_Data %>% 
  select(-TRADE_DT) %>% 
  cor(use = "p") %>% 
  corrplot::corrplot()

# merge index return data
IS_Factor_Daily_Data <- Index_Daily_Data %>% 
  filter(S_INFO_WINDCODE == "000001.SH") %>% 
  select(TRADE_DT, S_DQ_PCTCHANGE) %>% 
  inner_join(IS_Factor_Daily_Data, .) %>% 
  mutate(S_DQ_PCTCHANGE = S_DQ_PCTCHANGE / 100, 
         R5 = rollapply(S_DQ_PCTCHANGE, width = 5, Return.cumulative, fill = NA, align = "left"), 
         R5 = lead(R5), 
         R60 = rollapply(S_DQ_PCTCHANGE, width = 60, Return.cumulative, fill = NA, align = "left"), 
         R60 = lead(R60), 
         R240 = rollapply(S_DQ_PCTCHANGE, width = 240, Return.cumulative, fill = NA, align = "left"), 
         R240 = lead(R240)) %>% 
  select(-S_DQ_PCTCHANGE)

# correlation with future return
IS_Factor_Daily_Data %>% 
  # summarise_all(funs(sum(is.na(.))))
  filter(TRADE_DT >= "20101008") %>%
  select(-TRADE_DT) %>% 
  cor(use = "p")

IS_Factor_Daily_Data <- IS_Factor_Daily_Data %>% 
  select(TRADE_DT, TURN, ADVR, PCTLO, RLSP, PLD, PNI) %>% 
  mutate_all(na.locf, na.rm = FALSE) %>% 
  filter(complete.cases(.))

# PCA
ISI_Daily <- IS_Factor_Daily_Data %>% 
  select(-TRADE_DT) %>% 
  princomp( ~ ., data = .) %>% 
  # summary()
  predict() %>% 
  `[`(, 1) %>% 
  tibble(ISI = .) %>% 
  bind_cols(IS_Factor_Daily_Data[, 1], .)

save(ISI_Daily, file = "./data/ISI-Daily.RData")
