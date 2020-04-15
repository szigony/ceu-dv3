library(shinydashboard)

ui <- dashboardPage(
  
  dashboardHeader(title='Stocks'),
  
  dashboardSidebar(
    
    uiOutput('ui_tickers'),
    dateRangeInput(inputId = 'date',label = 'Select Date', start = Sys.Date() -365, end = Sys.Date()),
    infoBoxOutput('performance_infobox')
    
  ),
  
  dashboardBody(
    
    DT::dataTableOutput('ticker_data') ,
    plotOutput('data_ggplot')
    
  )
  
)

server <- function(input, output) {
  
  df <- get_sp500()
  
  output$ui_tickers <- renderUI(
    {
      selectInput(inputId = 'ticker', label = 'Tickers', choices = setNames(df$name, df$description), multiple = FALSE)
    }
  )
  
  output$selected_ticker_text <- renderText(input$ticker)
  
  reactive_df <- reactive(
    {
      return(get_data_by_ticker_and_date(ticker = input$ticker, start_date = input$date[1], end_date = input$date[2]))
    }
  )
  
  output$ticker_data <- DT::renderDataTable(
    {
      my_render_df(reactive_df())
    } 
  )

  output$data_ggplot <- renderPlot(
    {
      ggplot(reactive_df(), aes(date, close))+geom_line()+ theme_bw()
    }
  )
  
  output$performance_infobox <- renderInfoBox(
    {
      infoBox(title = 'Positive performance', value = paste0(round(sum(df$change > 0) / nrow(df) * 100, 0), '%'), icon = icon('thumbs-up'))
    }
  )
  
}

shinyApp(ui=ui, server = server)