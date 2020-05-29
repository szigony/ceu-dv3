### Header
header <- dashboardHeader(
  title = tags$div(
    tags$h4("Comparison of", style = "padding-right: 5px;"),
    tags$img(src = "netflix_logo.png", class = "header-logo"),
    tags$h4("behaviors", style = "padding-left: 5px;"),
    class = "title-div"
  ),
  titleWidth = 300
)




### Siderbar
sidebar <- dashboardSidebar(
  width = 300,
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
  )
)

### Body
body <- dashboardBody(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
  
  tabItems(
    tabItem(
      tabName = "dashboard",
      tags$h1("Dashboard"),
      DT::dataTableOutput("table")
    )
  )
)

### Dashboard
ui <- dashboardPage(
  skin = "red",
  title = "Comparison of Netflix behavior",
  
  header,
  sidebar,
  body
)