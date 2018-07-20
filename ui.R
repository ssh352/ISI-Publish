navbarPage(
  title = "中国股票市场监测系统", 
  # position = "fixed-top", 
  # footer = HTML("中国科学院管理、决策与信息系统重点实验室"), 
  
  # 大标签——投资者情绪
  tabPanel(
    title = "投资者情绪", 
    
    sidebarLayout(
      sidebarPanel(
        width = 3, 
        
        dateRangeInput(
          inputId = "IS_date_range", 
          label = "数据区间", 
          start = start_date, 
          end = Sys.Date(), 
          min = start_date, 
          max = Sys.Date(), 
          startview = "year", 
          language = "zh-CN", 
          separator = "至"
        ), 
        
        downloadButton(
          outputId = "download_ISI_data", 
          label = "下载数据"
        )
      ), 
      
      mainPanel(
        width = 9, 
        
        tabsetPanel(
          tabPanel(
            title = "月度指标"
          ), 
          
          tabPanel(
            title = "周度指标"
          ), 
          
          tabPanel(
            title = "日度指标", 
            
            plotOutput(
              outputId = "ISI_plot", 
              hover = "ISI_plot_hover", 
              brush = brushOpts(
                id = "ISI_plot_brush", 
                direction = "x"
              )
            ), 
            
            verbatimTextOutput(
              outputId = "ISI_point"
            ), 
            
            plotOutput(
              outputId = "ISI_plot_zoom"
            ), 
            
            dataTableOutput(
              outputId = "ISI_data"
            ), 
            
            verbatimTextOutput(
              outputId = "test1", 
              placeholder = TRUE
            )
          ), 
          
          tabPanel(
            title = "日内指标", 
            
            verbatimTextOutput(
              outputId = "test2"
            )
          )
        )
      )
    )
  ), 
  
  tabPanel(
    title = "流动性"
  ), 
  
  tabPanel(
    title = "联动性"
  ), 
  
  navbarMenu(
    title = "更多", 
    tabPanel(
      title = "关于"
    )
  )
)
