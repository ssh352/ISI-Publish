# Copyright Reserved

#####----Guidance----#####

library(tidyverse)
library(lubridate)
library(cnquant)
library(PerformanceAnalytics)

# 读取原始各数据集
load("~/Documents/Stock Data/D-Stock-Daily-Data.RData")
load("~/Documents/Stock Data/D-Stock-Daily-Moneyflow-tmp.RData")
load("~/Documents/Stock Data/D-Stock-Daily-L2-Indicators-tmp.RData")
load("~/Documents/Stock Data/D-Index-Daily-Data.RData")


#####----构建投资者情绪指标----#####

# Join data
Stock_Daily_Data <- Stock_Daily_Data %>% 
  left_join(Stock_Daily_Moneyflow) %>% 
  left_join(Stock_Daily_L2_Indicators)

# Wind SQL中计算得到的指标
IS_Factor_Daily_Data <- Stock_Daily_Data %>% 
  # 针对个股生成特定指标
  mutate(
    # 小额买卖比
    RSSP = BUY_TRADES_SMALL_ORDER / SELL_TRADES_SMALL_ORDER, 
    # 小额交易比例
    PSD = (BUY_VALUE_SMALL_ORDER + SELL_VALUE_SMALL_ORDER) * 10 / 2 / S_DQ_AMOUNT, 
    # 大额买卖比
    RLSP = BUY_TRADES_EXLARGE_ORDER / SELL_TRADES_EXLARGE_ORDER, 
    # 大额交易比例
    PLD = (BUY_VALUE_EXLARGE_ORDER + SELL_VALUE_EXLARGE_ORDER) * 10 / 2 / S_DQ_AMOUNT
  ) %>% 
  group_by(TRADE_DT) %>% 
  # 计算各项市场日度指标
  summarise(
    # 换手率
    TURN = weighted_mean(S_DQ_FREETURNOVER, S_DQ_MV), 
    # 涨跌成交比
    ADVR = sum(S_DQ_AMOUNT[S_DQ_PCTCHANGE > 0]) / sum(S_DQ_AMOUNT[S_DQ_PCTCHANGE < 0]), 
    # 涨跌比
    ADL = sum(S_DQ_PCTCHANGE > 0) / sum(S_DQ_PCTCHANGE < 0), 
    # 修正涨跌比
    ARMS = ADL / ADVR, 
    # 新高新低比
    HI2LO = sum(S_DQ_HIGH >= S_PQ_HIGH_52W_) / sum(S_DQ_LOW <= S_PQ_LOW_52W_), 
    # 创新高比率
    PCTHI = sum(S_DQ_HIGH >= S_PQ_HIGH_52W_) / n(),   # 理论上应该最多相等，实际上有4个大于的点，形如14.5 vs 14.499
    # 创新低比率
    PCTLO = sum(S_DQ_LOW <= S_PQ_LOW_52W_) / n(), 
    # 小额买卖比
    RSSP = weighted_mean(RSSP, S_DQ_MV), 
    # 小额交易比例
    PSD = weighted_mean(PSD, S_DQ_MV), 
    # 大额买卖比
    RLSP = weighted_mean(RLSP, S_DQ_MV), 
    # 大额交易比例
    PLD = weighted_mean(PLD, S_DQ_MV), 
    # 委比
    BAR = weighted_mean(S_LI_ENTRUSTRATE, S_DQ_MV)
  )

# 加入CSMAR中计算得到的指标

# ! QX_FundDiscountPremium是即时更新的
# 这个表用于计算封闭式基金折价率
IS_Factor_Daily_Data <- read_csmar_data("~/Documents/Stock Data/CSMAR/基金折溢价率表142319814/QX_FundDiscountPremium.xls", 
                                        col_types = c(rep("guess", 12), "numeric")) %>% 
  filter(FundTypeID == "S0502") %>% 
  transmute(TRADE_DT = TradingDate %>% ymd() %>% format("%Y%m%d"), 
            # 单只基金封闭式基金折价率
            CEFD = (NAV - ClosePrice) / ClosePrice) %>% 
  group_by(TRADE_DT) %>% 
  # 封闭式基金折价率
  summarise(CEFD = mean(CEFD)) %>% 
  ungroup() %>% 
  left_join(IS_Factor_Daily_Data, .)

# 下面的2个表用于计算新开户比率
# 早期
QX_Investor_Stop <- read_csmar_data("~/Documents/Stock Data/CSMAR/投资者情况统计表(停更)141126168/QX_InvestorStop.xls") %>% 
  filter(Datasgn == 3) %>% 
  transmute(TRADE_DT = EndDate %>% ymd() %>% format("%Y%m%d"), 
            # 新开户比率
            PNI = NewAccounts * 2 / 3 / 10000 / FinalActiveAccounts) %>% 
  filter(TRADE_DT < "20150508")

# 近期新表
IS_Factor_Daily_Data <- read_csmar_data("~/Documents/Stock Data/CSMAR/投资者情况统计表141334244/QX_Investor.xls") %>% 
  transmute(TRADE_DT = EndDate %>% ymd() %>% format("%Y%m%d"), 
            # 新开户比率
            PNI = NewInvestors / FinalInvestors) %>% 
  # 与早期表合并
  bind_rows(QX_Investor_Stop, .) %>% 
  # 与其他投资者情绪指标表合并
  left_join(IS_Factor_Daily_Data, .) %>% 
  # locf法填补这两个指标的缺失值
  mutate_at(vars(CEFD, PNI), zoo::na.locf, na.rm = FALSE, fromLast = TRUE, maxgap = 5)

# 保存投资者情绪指标数据
save(IS_Factor_Daily_Data, file = "./data/04-D-IS-Factor-Daily-Data.RData")


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
  filter(TRADE_DT >= "20101008") %>%
  select(-TRADE_DT) %>% 
  cor(use = "p")


#####----生成投资者情绪指数----#####

# 保留相关性分析通过的指标
IS_Factor_Daily_Data <- IS_Factor_Daily_Data %>% 
  select(TRADE_DT, TURN, ADVR, PCTLO, RLSP, PLD, PNI) %>% 
  filter(TRADE_DT >= "20101008") %>% 
  mutate_all(na.locf, na.rm = FALSE)

# PCA
ISI_Daily_Data <- IS_Factor_Daily_Data %>% 
  prcomp(~ . - TRADE_DT, data = ., scale = TRUE) %>% 
  predict() %>% 
  as_tibble() %>% 
  bind_cols(IS_Factor_Daily_Data, .) %>% 
  select(TRADE_DT, ISI = PC1) %>% 
  mutate(ISI = -ISI)

# 合并指数数据
ISI_Daily_Data <- Index_Daily_Data %>% 
  filter(S_INFO_WINDCODE == "000001.SH") %>% 
  select(TRADE_DT, S_DQ_CLOSE) %>% 
  left_join(ISI_Daily_Data, .)

# 保存此时数据
save(ISI_Daily_Data, file = "./data/04-D-ISI-Daily-Data-Ori.RData")

# 调整数据结构
ISI_Daily_Data <- ISI_Daily_Data %>% 
  mutate(TRADE_DT = ymd(TRADE_DT), 
         ISI = round(ISI * 400, 2)) %>% 
  rename(`交易日期` = TRADE_DT, 
         `投资者情绪指数` = ISI, 
         `上证指数` = S_DQ_CLOSE) %>% 
  gather(`指数`, `指数取值`, -`交易日期`) %>% 
  mutate(`指数` = factor(`指数`, levels = c("投资者情绪指数", "上证指数")))

# 计算一些其它辅助数据

# ISI_Daily vector
ISI_Daily <- ISI_Daily_Data %>% 
  filter(`指数` == "投资者情绪指数") %>% 
  pull(`指数取值`)

# 保存数据
save(ISI_Daily_Data, ISI_Daily, file = "./data/04-D-ISI-Daily-Data.RData")
