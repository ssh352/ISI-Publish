library(tidyverse)

load("./data/Liquidity/PIS-Data.RData")
load("./data/ISI-Daily.RData")

ISI_Daily <- ISI_Daily %>% 
  select(-ISI) %>% 

PIS_Long %>% 
  group_by(date) %>% 
  summarise(PIS = mean(PIS)) %>% 
  rename()

