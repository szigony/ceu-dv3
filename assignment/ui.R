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
  sidebarMenu(
    # Menu Items
    menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
    menuItem("Statistics", tabName = "statistics", icon = icon("chart-bar")),
    menuItem("Comparison", tabName = "comparison", icon = icon("people-carry")),
    
    # Inputs
    sliderInput("last_x_days_slider", h5("Last Days Shown"),
                min = 5, max = 90, value = 30, step = 5),
    uiOutput("is_movie"),
    uiOutput("title_selection")
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
          plotlyOutput("last_x_days_by_genre", height = "400px")
        )
      )
    ),
    
    # Statistics
    tabItem(
      tabName = "statistics",
      tags$h1("Statistics")
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