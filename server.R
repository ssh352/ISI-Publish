function(input, output) {
  ISI_Daily_Data_Mod <- reactive({
    ISI_Daily %>%
      filter(TRADE_DT >= input$ISI_daily_date_range[1], 
             TRADE_DT <= input$ISI_daily_date_range[2])
  })
  
  output$download_ISI_daily_data <- downloadHandler(
    filename = function() {
      paste0("ISI Data ", format(input$ISI_daily_date_range[1], "%Y%m%d"), "-", format(input$ISI_daily_date_range[2], "%Y%m%d"), ".csv")
    }, 
    
    content = function(file) {
      write_csv(ISI_Daily_Data_Mod(), file)
    }
  )
  
  output$ISI_daily_plot <- renderPlot({
    ISI_Daily_Data_Mod() %>% 
      ggplot(aes(x = TRADE_DT, y = value, color = key)) + 
      geom_line() + 
      labs(title = "中国股票市场投资者情绪指数", 
           caption = "参考文献：黄德龙, 文凤华, 杨晓光. 投资者情绪指数及中国股市的实证[J]. 系统科学与数学, 2009, 29(1):1-13.") + 
      theme_gray(base_family = "STKaiti")
  })
  
  output$ISI_daily_point <- renderPrint({
    nearPoints(ISI_Daily_Data_Mod(), input$ISI_daily_plot_hover)
  })
  
  output$ISI_daily_plot_zoom <- renderPlot({
    ISI_Daily_Data_Mod() %>% 
      filter(TRADE_DT >= input$ISI_daily_plot_brush$xmin, 
             TRADE_DT <= input$ISI_daily_plot_brush$xmax) %>% 
      ggplot(aes(x = TRADE_DT, y = value, color = key)) + 
      geom_line()
  })
  
  output$ISI_daily_data <- renderDataTable({
    ISI_Daily_Data_Mod()
  })
}
