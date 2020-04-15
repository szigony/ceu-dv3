# Load libraries
library(shiny)
library(rsconnect)

ui <- fluidPage(
  
  uiOutput('app')
  
)

server <- function(input, output) {
  
  USER <- reactiveValues('Logged' = FALSE)
  credentials <- list('test' = '123', 'ceu' = 'ceudata')
  
  output$app <- renderUI(
    {
      if (USER$Logged == FALSE) {
        wellPanel(
          textInput('username', 'Username'),
          textInput('password', 'Password'),
          actionButton('login', 'Log In')
        )
      } else {
        tags$h1("You're already logged in.") 
      }
      
    }
  )
  
  observeEvent(
    input$login,
    {
      if (credentials[[input$username]] == input$password) {
        USER$Logged = TRUE
      }
    }
  )
  
}

shinyApp(ui = ui, server = server)