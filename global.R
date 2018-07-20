library(shiny)
library(tidyverse)
library(lubridate)
library(DT)

load("./data/ISI-Daily.RData")

ISI_Daily <- ISI_Daily %>% 
  mutate(TRADE_DT = ymd(TRADE_DT), 
         ISI = ISI * 1000) %>% 
  rename(SSEC = S_DQ_CLOSE) %>% 
  gather(key, value, -TRADE_DT)

start_date <- ISI_Daily[1, "TRADE_DT", drop = T]
