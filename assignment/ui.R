# Load libraries
library(shiny)
library(shinydashboard)

header <- dashboardHeader(
  title = "My Netflix Behaviour"
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = "dashboard",
      tags$h1("Dashboard")
    )
  )
)

ui <- dashboardPage(
  header,
  sidebar,
  body
)