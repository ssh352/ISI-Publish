function(input, output) {
  
  # 投资者情绪—日度 ==========
  
  # 过滤样本区间
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
  
  # 下载样本区间内数据
  output$download_ISI_daily_data <- downloadHandler(
    filename = function() {
      paste0("ISI Data ", format(input$ISI_daily_date_range[1], "%Y%m%d"), "-", format(input$ISI_daily_date_range[2], "%Y%m%d"), ".csv")
    }, 
    
    content = function(file) {
      write_csv(ISI_Daily_Data_Selected(), file)
    }
  )
  
  # 主图
  output$ISI_daily_plot <- renderPlot({
    ISI_Daily_Data_Selected() %>% 
      ggplot(aes(x = `交易日期`, y = `指数取值`, color = `指数`)) + 
      geom_line() + 
      labs(title = "中国股票市场投资者情绪指数(日度)走势") + 
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
      ISI_Daily_Data_Selected() %>% 
        spread(`指数`, `指数取值`) %>% 
        arrange(desc(`交易日期`))
    }
  }, 
  rownames = FALSE)
  
  # 投资者情绪—月度 ==========
  
  # 过滤样本区间
  ISI_Monthly_Data_Selected <- reactive({
    ISI_Monthly_Data_Selected <- ISI_Monthly_Data %>%
      filter(between(`统计月度`, input$ISI_monthly_date_range[1], input$ISI_monthly_date_range[2]))
    
    if (input$ISI_monthly_disp_SSEC) {
      ISI_Monthly_Data_Selected
    } else {
      ISI_Monthly_Data_Selected %>% 
        filter(`指数` == "投资者情绪指数")
    }
    
  })
  
  # 下载样本区间内数据
  output$download_ISI_monthly_data <- downloadHandler(
    filename = function() {
      paste0("ISI Data ", format(input$ISI_monthly_date_range[1], "%Y%m%d"), "-", format(input$ISI_monthly_date_range[2], "%Y%m%d"), ".csv")
    }, 
    
    content = function(file) {
      write_csv(ISI_Monthly_Data_Selected(), file)
    }
  )
  
  # 主图
  output$ISI_monthly_plot <- renderPlot({
    ISI_Monthly_Data_Selected() %>% 
      ggplot(aes(x = `统计月度`, y = `指数取值`, color = `指数`)) + 
      geom_line() + 
      labs(title = "中国股票市场投资者情绪指数(月度)走势") + 
      theme_minimal(base_family = "STKaiti") + 
      theme(title = element_text(size = 17), 
            plot.title = element_text(family = "STHeiti", size = 18), 
            axis.text.x = element_text(size = 16), 
            axis.text.y = element_text(size = 16), 
            legend.text = element_text(size = 15))
  })
  
  # 鼠标悬停数据点信息
  output$ISI_monthly_point <- renderPrint({
    nearPoints(ISI_Monthly_Data_Selected(), input$ISI_monthly_plot_hover)
  })
  
  # 鼠标框选放大图片
  output$ISI_monthly_plot_zoom <- renderPlot({
    req(input$ISI_monthly_plot_brush)
    ISI_Monthly_Data_Selected() %>% 
      filter(between(`统计月度`, input$ISI_monthly_plot_brush$xmin, input$ISI_monthly_plot_brush$xmax)) %>% 
      ggplot(aes(x = `统计月度`, y = `指数取值`, color = `指数`)) + 
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
  output$ISI_monthly_data <- renderDataTable({
    if (input$ISI_monthly_disp_DT) {
      ISI_Monthly_Data_Selected() %>% 
        spread(`指数`, `指数取值`) %>% 
        arrange(desc(`统计月度`))
    }
  }, 
  rownames = FALSE)
  
  # 市场流动性 ==========
  
  # 过滤样本区间
  Liquidity_Daily_Data_Selected <- reactive({
    Liquidity_Daily_Data_Selected <- Liquidity_Daily_Data %>%
      filter(between(`交易日期`, input$Liquidity_daily_date_range[1], input$Liquidity_daily_date_range[2]))
    
    if (input$Liquidity_daily_disp_SSEC) {
      Liquidity_Daily_Data_Selected
    } else {
      Liquidity_Daily_Data_Selected %>% 
        filter(`指数` == "市场流动性指数")
    }
    
  })
  
  # 下载样本区间内数据
  output$download_Liquidity_daily_data <- downloadHandler(
    filename = function() {
      paste0("Liquidity Data ", format(input$Liquidity_daily_date_range[1], "%Y%m%d"), "-", format(input$Liquidity_daily_date_range[2], "%Y%m%d"), ".csv")
    }, 
    
    content = function(file) {
      write_csv(Liquidity_Daily_Data_Selected(), file)
    }
  )
  
  # 主图
  output$Liquidity_daily_plot <- renderPlot({
    Liquidity_Daily_Data_Selected() %>% 
      ggplot(aes(x = `交易日期`, y = `指数取值`, color = `指数`)) + 
      geom_line() + 
      labs(title = "中国股票市场流动性指数(日度)走势") + 
      theme_minimal(base_family = "STKaiti") + 
      theme(title = element_text(size = 17), 
            plot.title = element_text(family = "STHeiti", size = 18), 
            axis.text.x = element_text(size = 16), 
            axis.text.y = element_text(size = 16), 
            legend.text = element_text(size = 15))
  })
  
  # 鼠标悬停数据点信息
  output$Liquidity_daily_point <- renderPrint({
    nearPoints(Liquidity_Daily_Data_Selected(), input$Liquidity_daily_plot_hover)
  })
  
  # 鼠标框选放大图片
  output$Liquidity_daily_plot_zoom <- renderPlot({
    req(input$Liquidity_daily_plot_brush)
    Liquidity_Daily_Data_Selected() %>% 
      filter(between(`交易日期`, input$Liquidity_daily_plot_brush$xmin, input$Liquidity_daily_plot_brush$xmax)) %>% 
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
  output$Liquidity_daily_data <- renderDataTable({
    if (input$Liquidity_daily_disp_DT) {
      Liquidity_Daily_Data_Selected() %>% 
        spread(`指数`, `指数取值`) %>% 
        arrange(desc(`交易日期`))
    }
  }, 
  rownames = FALSE)
  
  # 股票间交互强度 ==========
  
  # 过滤样本区间
  Correlation_Daily_Data_Selected <- reactive({
    Correlation_Daily_Data_Selected <- Correlation_Daily_Data %>%
      filter(between(`交易日期`, input$Correlation_daily_date_range[1], input$Correlation_daily_date_range[2]))
    
    if (input$Correlation_daily_disp_SSEC) {
      Correlation_Daily_Data_Selected
    } else {
      Correlation_Daily_Data_Selected %>% 
        filter(`指数` == "股票间交互强度指数")
    }
    
  })
  
  # 下载样本区间内数据
  output$download_Correlation_daily_data <- downloadHandler(
    filename = function() {
      paste0("Correlation Data ", format(input$Correlation_daily_date_range[1], "%Y%m%d"), "-", format(input$Correlation_daily_date_range[2], "%Y%m%d"), ".csv")
    }, 
    
    content = function(file) {
      write_csv(Correlation_Daily_Data_Selected(), file)
    }
  )
  
  # 主图
  output$Correlation_daily_plot <- renderPlot({
    Correlation_Daily_Data_Selected() %>% 
      ggplot(aes(x = `交易日期`, y = `指数取值`, color = `指数`)) + 
      geom_line() + 
      labs(title = "中国股票市场股票间交互强度指数(日度)走势") + 
      theme_minimal(base_family = "STKaiti") + 
      theme(title = element_text(size = 17), 
            plot.title = element_text(family = "STHeiti", size = 18), 
            axis.text.x = element_text(size = 16), 
            axis.text.y = element_text(size = 16), 
            legend.text = element_text(size = 15))
  })
  
  # 鼠标悬停数据点信息
  output$Correlation_daily_point <- renderPrint({
    nearPoints(Correlation_Daily_Data_Selected(), input$Correlation_daily_plot_hover)
  })
  
  # 鼠标框选放大图片
  output$Correlation_daily_plot_zoom <- renderPlot({
    req(input$Correlation_daily_plot_brush)
    Correlation_Daily_Data_Selected() %>% 
      filter(between(`交易日期`, input$Correlation_daily_plot_brush$xmin, input$Correlation_daily_plot_brush$xmax)) %>% 
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
  output$Correlation_daily_data <- renderDataTable({
    if (input$Correlation_daily_disp_DT) {
      Correlation_Daily_Data_Selected() %>% 
        spread(`指数`, `指数取值`) %>% 
        arrange(desc(`交易日期`))
    }
  }, 
  rownames = FALSE)
  
}
