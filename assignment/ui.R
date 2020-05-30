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
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Statistics", tabName = "statistics", icon = icon("chart-bar")),
    menuItem("Comparison", tabName = "comparison", icon = icon("people-carry"))
  )
)

### Body
body <- dashboardBody(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
  
  tabItems(
    tabItem(
      tabName = "dashboard",
      
      fluidRow(
        valueBoxOutput("tv_shows", width = 3),
        valueBoxOutput("episodes_watched", width = 3),
        valueBoxOutput("movies_watched", width = 3),
        valueBoxOutput("time_wasted", width = 3)
      ),
      
      fluidRow(
        column(width = 10, offset = 1,
          plotOutput("last_x_days_chart")
        )
      )
    ),
    
    tabItem(
      tabName = "statistics",
      tags$h1("Statistics")
    ),
    
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