### Header
header <- dashboardHeader(
  title = "My Netflix Behaviour"
)

### Siderbar
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
  )
)

### Body
body <- dashboardBody(
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
  
  header,
  sidebar,
  body
)