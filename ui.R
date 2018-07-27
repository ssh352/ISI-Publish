navbarPage(
  title = "中国股票市场监测系统", 
  # position = "fixed-top", 
  # footer = HTML("中国科学院管理、决策与信息系统重点实验室"), 
  # themeSelector(), 
  
  # 大标签——投资者情绪
  tabPanel(
    title = "投资者情绪", 
    
    # 小标签--指标频率
    tabsetPanel(
      selected = "日度指标", 
      
      # 月度指标
      tabPanel(
        title = "月度指标"
      ), 
      
      # # 周度指标
      # tabPanel(
      #   title = "周度指标"
      # ),
      
      # 日度指标
      tabPanel(
        title = "日度指标", 
        
        # 日度指标下的sidebar布局
        sidebarLayout(
          # sidebar面板
          sidebarPanel(
            width = 2, 
            
            # 数据区间
            dateRangeInput(
              inputId = "ISI_daily_date_range", 
              label = "数据区间", 
              start = start_date, 
              end = Sys.Date(), 
              min = start_date, 
              max = Sys.Date(), 
              startview = "year", 
              language = "zh-CN", 
              separator = "至"
            ), 
            
            # 是否显示上证指数
            checkboxInput(
              inputId = "ISI_daily_disp_SSEC", 
              label = "显示上证指数", 
              value = TRUE
            ), 
            
            # 是否显示DT
            checkboxInput(
              inputId = "ISI_daily_disp_DT", 
              label = "显示数据"
            ), 
            
            # 下载数据
            downloadButton(
              outputId = "download_ISI_daily_data", 
              label = "下载数据"
            )
          ), 
          
          # 主面板
          mainPanel(
            width = 10, 
            
            # 走势分析
            uiOutput(
              outputId = "ISI_daily_analysis"
            ), 
            
            br(), 
            
            # 主图
            plotOutput(
              outputId = "ISI_daily_plot", 
              hover = "ISI_daily_plot_hover", 
              brush = brushOpts(
                id = "ISI_daily_plot_brush", 
                direction = "x"
              )
            ), 
            
            # 鼠标悬停数据点信息
            verbatimTextOutput(
              outputId = "ISI_daily_point"
            ), 
            
            br(), 
            
            # 鼠标框选放大图片
            conditionalPanel(
              condition = "input.ISI_daily_plot_brush", 
              plotOutput(
                outputId = "ISI_daily_plot_zoom"
              )
            ), 
            
            # DT数据展示
            dataTableOutput(
              outputId = "ISI_daily_data"
            )
          )
        )
      ), 
      
      # 日内高频指标
      tabPanel(
        title = "日内指标"
      ), 
      
      # 投资者情绪说明
      tabPanel(
        title = "投资者情绪说明", 
        
        fluidRow(
          
          # 左侧留白
          column(
            width = 2
          ), 
          
          # 中间放投资者情绪说明
          column(
            width = 8, 
            br(), br(), 
            p("  投资者情绪表现了投资者对整个市场或者某一特定股票的整体态度。", 
              br(), 
              "  投资者情绪并不总是依赖于基本面，而往往是一种对更短期事件的反应。
               投资者情绪通过投资者的实际行动来体现，即股票的买卖，最终表现为股票价格的变动、
               换手率的变化等。", 
              br(), 
              "  当投资者情绪高涨时，往往意味着股票价格有上升的态势；
               而当投资者情绪低落时，往往意味着股票价格有下降的态势。
               投资者情绪对于投资者判断市场态势以及特定股票价格高估还是低估提供了重要的依据，
               可以帮助投资者更好地进行选择。", 
              br(), 
              "  现在已经有很多指标来刻画投资者情绪，
               我们的系统集成了那些指标并且放入了我们自己构建的指标。
               我们的系统展现了四种频度的投资者情绪指标，分别是月度指标、周度指标、日度指标和日内指标。
               期望多维度、多频度的投资者情绪指标可以帮助投资者更好地做出决策。"
            )
          ), 
          
          # 右侧留白
          column(
            width = 2
          )
        )
      )
    )
  ), 
  
  # 大标签——流动性
  tabPanel(
    title = "流动性"
  ), 
  
  # 大标签——联动性
  tabPanel(
    title = "联动性"
  ), 
  
  # 大标签——更多(可内涵更多大标签)
  navbarMenu(
    title = "更多", 
    tabPanel(
      title = "关于"
    )
  )
)
