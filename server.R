function(input, output) {
  
  # 投资者情绪—日度-过滤样本区间
  ISI_Daily_Data_Selected <- reactive({
    ISI_Daily_Data_Selected <- ISI_Daily_Data %>%
      filter(between(`交易日期`, input$ISI_daily_date_range[1], input$ISI_daily_date_range[2]))
    
    if (input$ISI_daily_disp_SSEC) {
      ISI_Daily_Data_Selected
    } else {
      ISI_Daily_Data_Selected %>% 
        filter(`指数` == "投资者情绪指数")
    }
    
  })
  
  # 投资者情绪—日度-下载样本区间内数据
  output$download_ISI_daily_data <- downloadHandler(
    filename = function() {
      paste0("ISI Data ", format(input$ISI_daily_date_range[1], "%Y%m%d"), "-", format(input$ISI_daily_date_range[2], "%Y%m%d"), ".csv")
    }, 
    
    content = function(file) {
      write_csv(ISI_Daily_Data_Selected(), file)
    }
  )
  
  # 走势分析
  output$ISI_daily_analysis <- renderUI({
    h5("昨日的投资者情绪指数值为", 
       most_recent_ISI_daily, 
       "点, 较前一交易日", 
       if_else(change_ISI_daily > 0, "上升", "下降"), 
       change_ISI_daily, "点.")
  })
  
  # 投资者情绪—日度-主图
  output$ISI_daily_plot <- renderPlot({
    ISI_Daily_Data_Selected() %>% 
      ggplot(aes(x = `交易日期`, y = `指数取值`, color = `指数`)) + 
      geom_line() + 
      labs(title = "中国股票市场投资者情绪指数(日度)走势", 
           caption = "参考文献：黄德龙, 文凤华, 杨晓光. 投资者情绪指数及中国股市的实证[J]. 系统科学与数学, 2009, 29(1):1-13.") + 
      theme_minimal(base_family = "STKaiti") + 
      theme(title = element_text(size = 17), 
            plot.title = element_text(family = "STHeiti", size = 18), 
            axis.text.x = element_text(size = 16), 
            axis.text.y = element_text(size = 16), 
            legend.text = element_text(size = 15))
  })
  
  # 鼠标悬停数据点信息
  output$ISI_daily_point <- renderPrint({
    nearPoints(ISI_Daily_Data_Selected(), input$ISI_daily_plot_hover)
  })
  
  # 鼠标框选放大图片
  output$ISI_daily_plot_zoom <- renderPlot({
    req(input$ISI_daily_plot_brush)
    ISI_Daily_Data_Selected() %>% 
      filter(between(`交易日期`, input$ISI_daily_plot_brush$xmin, input$ISI_daily_plot_brush$xmax)) %>% 
      ggplot(aes(x = `交易日期`, y = `指数取值`, color = `指数`)) + 
      geom_line() + 
      labs(title = "局部走势") + 
      theme_minimal(base_family = "STKaiti") + 
      theme(title = element_text(size = 17), 
            plot.title = element_text(family = "STHeiti", size = 18), 
            axis.text.x = element_text(size = 16), 
            axis.text.y = element_text(size = 16), 
            legend.text = element_text(size = 15))
  })
  
  # DT数据展示
  output$ISI_daily_data <- renderDataTable({
    if (input$ISI_daily_disp_DT) {
      ISI_Daily_Data_Selected()
    }
  }, 
  rownames = FALSE)
}
