library(shiny)
library(shinythemes)
library(tidyverse)
library(lubridate)
library(DT)

load("./data/ISI-Daily-Data.RData")

ISI <- ISI_Daily_Data %>% 
  filter(`指数` == "投资者情绪指数") %>% 
  pull(`指数取值`)

most_recent_ISI_daily <- nth(ISI, -1)

change_ISI_daily <- nth(ISI, -1) - nth(ISI, -2)
