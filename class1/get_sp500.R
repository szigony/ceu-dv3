# Load libraries
library(shiny)
library(jsonlite)
library(data.table)
library(httr)
library(rtsdata)
library(DT)
library(TTR)
library(plotly)
library(ggplot2)
library(devtools)

# Source functions
source('class1/shiny_functions.R')

ui <- fluidPage(
  
  uiOutput('ui_tickers'),
  textOutput('selected_ticker_text')
  
)

server <- function(input, output) {
  
  df <- get_sp500()
  output$ui_tickers <- renderUI(
    {
      selectInput(inputId = 'ticker', label = 'Tickers', choices = setNames(df$name, df$description), multiple = FALSE)
    }
  )
  
  output$selected_ticker_text <- renderText(
    {
      paste('ID of the selection:', input$ticker)
    }
  )
  
}

shinyApp(ui = ui, server = server)