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

    # Conditional Inputs
    conditionalPanel(
      condition = "input.smenu == 'overview'",
      sliderInput("last_x_days_slider", h5("Last Days Shown"),
                  min = 5, max = 90, value = 30, step = 5)
    ),
    
    conditionalPanel(
      condition = "input.smenu == 'statistics'",
      dateRangeInput(inputId = "date", h5("Date Range"),
                     start = "2020-01-01", end = Sys.Date()),
      numericInput(inputId = "show_top", h5("Top Views Shown"), value = 5)
    ),
    
    conditionalPanel(
      condition = "input.smenu == 'comparison'",
      fileInput("file", h5("Upload Your Netflix History")),
      htmlOutput("netflix_history_file")
    ),
    
    # Static Inputs
    uiOutput("is_movie"),
    uiOutput("title_selection"),
    
    # Disclaimer
    htmlOutput("disclaimer")
  )
)

### Body
body <- dashboardBody(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
  
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
          title = "Total Number of Views", width = 9, status = "primary",
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
      tags$h1("Comparison")
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