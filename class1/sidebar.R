# Load libraries
library(shiny)

# Source functions
source_url('bit.ly/ceushiny')

ui <- fluidPage(
  
  sidebarLayout(
    
    sidebarPanel(
      uiOutput('ui_tickers'),
      dateRangeInput(inputId = 'date', label = 'Select Date', start = Sys.Date() - 365, end = Sys.Date())
    ),
    
    mainPanel(
      
      tabsetPanel(
        tabPanel('data', DT::dataTableOutput('ticker_data')),
        tabPanel('plot', plotOutput('data_ggplot'))
        # tabPanel('plot', plotlyOutput('data_plotly', width = '60%', height = '800px'))
      )
      
    )
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
  
  # output$data_plotly <- renderPlotly(
  #   {
  #     get_plot_of_data(reactive_df())
  #   }
  # )
  
  output$data_ggplot <- renderPlot(
    {
      ggplot(reactive_df(), aes(date, close))+geom_line()+ theme_bw()
    }
  )

}

shinyApp(ui = ui, server = server)