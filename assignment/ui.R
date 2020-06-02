### Header
header <- dashboardHeader(
  title = tags$div(
    tags$img(src = "netflix_logo.png", class = "header-logo"),
    tags$h4("Behavior", style = "padding-left: 5px;"),
    class = "title-div"
  )
)

### Sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(id = "smenu",
    # Menu Items
    menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
    menuItem("Statistics", tabName = "statistics", icon = icon("chart-bar")),
    menuItem("Comparison", tabName = "comparison", icon = icon("people-carry")),

    # Static Inputs
    uiOutput("title_selection"),

    # Conditional Inputs    
    conditionalPanel(
      condition = "input.smenu == 'overview'",
      sliderInput("last_x_days_slider", h5("Last Days Shown"),
                  min = 5, max = 90, value = 30, step = 5)
    ),
    
    conditionalPanel(
      condition = "input.smenu == 'statistics'",
      numericInput(inputId = "show_top", h5("Top Views Shown"), value = 5)
    ),
    
    conditionalPanel(
      condition = "input.smenu == 'statistics' | input.smenu == 'comparison'",
      dateRangeInput(inputId = "date", h5("Date Range"),
                     start = "2020-01-01", end = Sys.Date())
    ),
    
    conditionalPanel(
      condition = "input.smenu == 'overview' | input.smenu == 'statistics'",
      uiOutput("is_movie"),
      htmlOutput("disclaimer")
    ),
    
    conditionalPanel(
      condition = "input.smenu == 'comparison'",
      fileInput("file", h5("Upload Your Netflix History"), accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      htmlOutput("netflix_history_file"),
      htmlOutput("comparison_disclaimer")
    )

  )
)

### Body
body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    includeHTML(("google-analytics.html"))
  ),
  
  tabItems(
    # Overview
    tabItem(
      tabName = "overview",
      
      fluidRow(
        valueBoxOutput("tv_shows", width = 3),
        valueBoxOutput("episodes_watched", width = 3),
        valueBoxOutput("movies_watched", width = 3),
        valueBoxOutput("time_wasted", width = 3)
      ),
      
      fluidRow(
        box(
          title = uiOutput("last_x_days_title"), width = 9, status = "primary",
          plotlyOutput("last_x_days_chart", height = "400px")
        ),
        
        box(
          title = "Breakdown by Genres", width = 3, status = "success",
          plotlyOutput("last_x_days_by_genre", height = "400px"),
          footer = "A title can belong to multiple genres."
        )
      )
    ),
    
    # Statistics
    tabItem(
      tabName = "statistics",
      
      fluidRow(
        box(
          title = "Cumulative Number of Views in this Period", width = 9, status = "primary",
          plotlyOutput("total_no_of_views")
        ),
        
        box(
          title = "Most Popular TV Shows", width = 3, status = "success",
          DT::dataTableOutput("popular_tv_shows")
        )
      ),
      
      fluidRow(
        box(
          title = "Most Popular Movies", width = 3, status = "danger",
          DT::dataTableOutput("popular_movies")
        ),
        
        box(
          title = "Daily Views", width = 9, status = "warning",
          plotlyOutput("daily_views")
        )
      )
    ),
    
    # Comparison
    tabItem(
      tabName = "comparison",

      fluidRow(
        infoBoxOutput("match", width = 4),

        box(
          title = "# of TV Shows", width = 4, status = "primary", height = 230,
          plotlyOutput("number_of_tv_shows")
        ),
        
        box(
          title = "# of Movies", width = 4, status = "danger", height = 230,
          plotlyOutput("number_of_movies")
        )
      ),
      
      fluidRow(
        box(
          title = "Comparison of All Time Total # of TV Show Views", width = 12, status = "success", height = 350,
          plotlyOutput("compare_views")
        )
      )

    )
  )
)

### Dashboard
ui <- dashboardPage(
  skin = "red",
  title = "Netflix Behavior",
  
  header,
  sidebar,
  body
)