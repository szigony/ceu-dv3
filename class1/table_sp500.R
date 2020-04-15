# Load libraries
library(shiny)
library(devtools)

# Source functions
source_url('bit.ly/ceushiny')

ui <- fluidPage(

  uiOutput('ui_tickers'),
  textOutput('selected_ticker_text'),
  tags$br(),
  dateRangeInput(inputId = 'date', label = 'Select Date', start = Sys.Date() - 365, end = Sys.Date()),
  tags$br(),
  DT::dataTableOutput('ticker_data')
  
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
  
  reactive_df <- reactive(
    {
      return(get_data_by_ticker_and_date(ticker = input$ticker, start_date = input$date[1], end_date = input$date[2]))
    }
  )
  
  output$ticker_data <- DT::renderDataTable(
    {
      my_render_df(reactive_df())
    },
    extensions = 'Buttons', options = list(
      dom = 'Bfrtip',
      buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
    )
  )
  
}

shinyApp(ui = ui, server = server)