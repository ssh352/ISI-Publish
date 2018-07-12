# Copyright Reserved

#####----Guidance----#####

library(tidyverse)
library(lubridate)
library(quantmod)
library(DT)


#####----读取数据----#####

Data_Monthly <- read_tsv("./Data/BW/QX_ISI.txt", 
         col_names = c("统计月度", "上月封闭基金平均折价率", "IPO首日收益率均值", "IPO数", 
                       "新增开户数", "上月市场换手率", "上月消费者信心", "投资者情绪指数"), 
         col_types = "cddidddd", skip = 3) %>% 
  mutate(`统计月度` = ceiling_date(as.Date(as.yearmon(`统计月度`)), "month") - days(1)) %>% 
  arrange(`统计月度`)

Data_Monthly <- getSymbols("^SSEC", src = "yahoo", auto.assign = FALSE, from = "2003-01-01", to = "2018-02-28") %>% 
  to.monthly(indexAt = "lastof") %>% 
  as.data.frame() %>% 
  rownames_to_column("统计月度") %>% 
  as_tibble() %>% 
  select(`统计月度`, `上证指数` = ..Close) %>% 
  mutate(`统计月度` = ymd(`统计月度`)) %>% 
  left_join(Data_Monthly, .)



#####----做表----#####

datatable(Data_Monthly)


#####----做图----#####

Data_Monthly %>% 
  ggplot(aes(x = `统计月度`, y = `投资者情绪指数`)) + 
  geom_line() + 
  theme_gray(base_family = "STKaiti")

write.csv(Data_Monthly, "investor.csv")
