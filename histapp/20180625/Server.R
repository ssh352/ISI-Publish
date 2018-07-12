
library(shiny)
library(tidyverse)
library(lubridate)
library(xts)
library(DT)
library(recharts)
library(datasets)
library(reshape2)


shinyServer(function(input, output) {
  
  #This function is repsonsible for loading in the selected file
  filedata <- reactive({
    infile <- input$datafile
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    read.csv(infile$datapath)
  })
  

  data.selected <- reactive({
    
    df <- filedata()
    
    if(is.null(df)){return ()}
    
    # =======================================================
    # Control sample 
    start <- as.Date(input$date.start)
    end <- as.Date(input$date.end)      

    df$统计月度 <- as.Date(df$统计月度)
    df <- subset(df, 统计月度>=start & 统计月度<=end)
    # =======================================================
    df
  })
  
  
  #This previews the CSV data file
  output$filetable <- renderDataTable({
    # head(filedata()[-1],input$obs)
    data.selected()[-1]
  })
  
  
    output$downloadData <- downloadHandler(
      
      filename = function() {
        data <- data.selected()[-1]
        paste('data-', Sys.Date(), '.csv', sep='')
      },
      content = function(con) {
        data <- data.selected()[-1]
        write.csv(data, con)
      }
    )
    

  
  output$plot.graph <- renderEChart({
    
    df <-data.selected()
    
    if(is.null(df)){return ()}
    
    df <- melt(df[-1], id.vars=c("统计月度"))
    df$variable <- as.factor(df$variable)
    library(recharts)
    
    withProgress(message = '正在使用洪荒之力加载数据',
                 detail = '这将会花费一些时间，请耐心等待！...', value = 5, {
                   
                   g <- echartr(df, 统计月度, value, variable, type='line', elementId = ) %>%
                     setTitle('各数据变量时间序列图') %>% 
                     setSymbols('emptycircle')
                   
                   # Pause for 0.2 seconds to simulate a long computation.
                   Sys.sleep(0.0001)
                 })
    g
  })
  
  
  #The following set of functions populate the column selectors
  output$toCol <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("to", "To:",items)
    
  })
  
  output$fromCol <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("from", "From:",items)
    
  })
  
  #The checkbox selector is used to determine whether we want an optional column
  output$amountflag <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    checkboxInput("amountflag", "Use values?", FALSE)
  })
  
  #If we do want the optional column, this is where it gets created
  output$amountCol <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    #Let's only show numeric columns
    nums <- sapply(df, is.numeric)
    items=names(nums[nums])
    names(items)=items
    selectInput("amount", "Amount:",items)
  })
  
})