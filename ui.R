
library(shiny)
library(tidyverse)
library(lubridate)
library(xts)
library(DT)
library(recharts)
library(datasets)
library(reshape2)
library(scales)



shinyUI(fluidPage(
  fluidRow(
    # dividing header panel in two columns      
    # column one contains the title
    column(width = 10, # width of first column 
           style = "font-size: 20pt; line-height: 40pt; width = 100", # font size etc.
           tags$strong("股票市场投资者情绪监测系统")), # "tags" is for using html-functions within the shiny app
    
    # column two
    column(width = 2,
           tags$head(tags$img(src='logo-cas.jpg', align = "left", heigth=60, width=60)),
           tags$head(tags$img(src='logo-amss.png', align = "left", heigth=160, width=160))) # add image from url
  ),
  
  sidebarPanel(
    
    style = "background-color: light gray;", # choose background color
    tags$style(type='text/css', # add css-style to the lists of selected categories and the dropdown menue  
               ".selectize-input { font-size: 12pt; line-height: 13pt;} 
               .selectize-dropdown { font-size: 12pt; line-height: 13pt; }"),
    width = 3, # set panel width
    
    
    #Selector for file upload
    fileInput('datafile', 'Choose CSV file',
              accept=c('text/csv', 'text/comma-separated-values,text/plain')),
    #These column selectors are dynamically created when the file is loaded
    
    # h5("1. 选择时间段"),
    # dateInput('date.start',
    #           label = '1.1 样本起始时间: yyyy-mm-dd',
    #           value = "2003-01-31"
    # ),
    # dateInput('date.end',
    #           label = '1.2 样本结束时间: yyyy-mm-dd',
    #           value = "2018-02-28"
    # ),
    h5(""),
    selectInput("Normalization", "数据是否标准化", choices = c("否","是"), selected = "否", selectize = F),
    
    h5(""),
    h5("下载数据"),
    downloadLink("downloadData", "Download")
    # h5("2. 平滑数据"),
    # h5("3. .....")
  ),
  mainPanel(
    tabsetPanel(
      tabPanel("月度指标",
               h5("1. 图像展示"),
               eChartOutput("plot.graph"),
               br("备注：该投资者情绪指数的计算方法来源于如下文献，Baker, M., & Wurgler, J. (2006). Investor sentiment and the cross‐section of stock returns. The Journal of Finance, 61(4), 1645-1680."),
               # tags$head(tags$style("
               #    #number{display:inline
               # }")),
               # h5('本月的投资者情绪指数为',style="display:inline"), 
               br(),
               h5(textOutput("textWithNumber")),
               br(),
               br(),
               h5("2. 数据展示"),
               dataTableOutput("filetable")
               ),
      tabPanel("周度指标",tableOutput("geotable")),
      tabPanel("日度指标",tableOutput("gtable")),
      tabPanel("高频指标",tableOutput("eotable"))
  )
)))