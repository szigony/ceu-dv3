# Load libraries
library(shinydashboard)

ui <- dashboardPage(
  
  dashboardHeader(
    title = 'Stocks'
  ),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem('Control', tabName = 'control', icon = icon('database'),
               uiOutput('ui_tickers'),
               dateRangeInput(inputId = 'date', label = 'Select Date', start = Sys.Date() - 365, end = Sys.Date())),
      menuItem('Plot', tabName = 'plot', icon = icon('table'))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = 'control', 
        tags$h1('Select date and ticker')
      ),
      tabItem(
        tabName = 'plot',
        tabPanel('plot', div(plotOutput('data_ggplot'), align = 'center'))
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