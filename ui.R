navbarPage(
  title = "中国股票市场监测系统", 
  # position = "fixed-top", 
  # footer = HTML("中国科学院管理、决策与信息系统重点实验室"), 
  # themeSelector(), 
  
  # 大标签——投资者情绪 ==========
  tabPanel(
    title = "投资者情绪", 
    
    # 小标签--指标频率
    tabsetPanel(
      selected = "日度指标", 
      
      # 月度指标 ==========
      tabPanel(
        title = "月度指标", 
        
        eChartOutput("plot.graph")
      ), 
      
      # # 周度指标 ==========
      # tabPanel(
      #   title = "周度指标"
      # ),
      
      # 日度指标 ==========
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
      
      # 日内高频指标 ==========
      tabPanel(
        title = "日内指标"
      ), 
      
      # 投资者情绪说明 ==========
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
  
  # 大标签——流动性 ==========
  tabPanel(
    title = "流动性"
  ), 
  
  # 大标签——联动性 ==========
  tabPanel(
    title = "联动性"
  ), 
  
  # 大标签——更多(可内涵更多大标签) ==========
  navbarMenu(
    title = "更多", 
    
    "----", 
    
    tabPanel(
      title = "关于", 
      
      img(src = "bar-madis.png", align = "center"), 
      br(), br(), 
      p("  中国科学院管理、决策与信息系统重点实验室成立于1988年5月，是中国运筹学、系统工程、
        管理科学、计算机科学和应用数学的主要研究基地和高级人才培养基地之一。
        中国工程院院士、中国运筹学和系统工程等学科的主要开创人之一许国志研究员曾担任重点实验室的
        首任室主任。"), 
      p("  实验室的总体定位是在“顶天立地”的学术宗旨之下，把实验室建设成中国管理科学、系统工程、
        经济与金融决策、知识科学领域的顶尖研究中心，中央和地方政府社会经济问题的决策咨询中心之一，
        行业和国防工业管理和决策问题的方法和工具的研发中心之一，国内外重要学术交流中心之一，
        以及高级人才培养基地之一。实验室的研究使命一是立足于国际学术前沿，不断在管理科学、系统工程、
        经济与金融决策、知识科学的基础理论和方法研究中取得领先性的学术成果，跻身国际学术前列；
        二是面向国民经济主战场，密切跟踪中国社会经济改革和发展过程中的重大管理问题、
        宏观决策问题并及时开展系统研究，同时研制管理信息系统和决策支持系统，
        为政府重大决策提供支持与参考依据，发挥中央和政府决策部门的思想库角色。
        中国在定量管理领域的两大全国性一级学会——中国系统工程学会和中国运筹学会——都挂靠在实验室，
        两个学会的理事长、秘书长，都是由实验室成员分别担任，体现出实验室在国内相关学科领域的领导地位。"), 
      p("  实验室每年向政府决策部门提交大量的政策研究报告，
        得到了国家领导人和政府有关部门的高度重视并批转落实；
        实验室为国家有关部门开发了一批决策支持平台，为行业和国防工业提供了一系列算法和工具；
        实验室每年在国际顶级期刊上发表了一批高水平的学术论文，获得国际同行的高度评价；
        实验室开辟了多个研究领域，吸引了国际国内的同行的后续工作。实验室的研究工作获得了国际同行的承认，
        获得了一些重要的国际奖励，并且实验室相当一部分成员在国际学术组织任职。
        重点实验室成员曾荣获“2014年度美国质量学会兰卡斯特奖章”（ASQ Lancaster Medal）、
        亚太质量组织（APQO）“首届费根堡终身荣誉奖”、亚洲质量网“石川馨—狩野奖”、
        发展中国家科学院院士（TWAS Fellow）、入选国际系统与控制科学院
        （The International System And The Control Science Academy）院士、
        荣获“Green Award for Business Intelligence and Computational Finance”、
        以及国际信息技术和定量管理科学院（The International Academy of Information Technology and 
        Quantitative Management）的“2014 Jr. Walter Scott奖”等。"), 
      br(), 
      p("地址：北京市海淀区中关村东路55号 邮编：100190", align = "right")
    )
  )
)
