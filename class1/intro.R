library(shiny)

ui <- fluidPage(
  
  h1('hello ceu'),
  h2('smaller text'),
  tags$br(),
  tags$hr(),
  tags$code('print("hello")'),
  div(h3('change text'), style="color:blue"),
  
  sliderInput(inputId = 'age', label = 'Age', min = 0, max = 100, value = 50, step = 1),
  textInput(inputId = 'my_name', label = 'first text input', value = '', placeholder = 'write here'),
  textOutput('age_name_text')
  
)

server <- function(input, output) {
  
  output$age_name_text <- renderText(
    {
      return(paste0('name: ', input$my_name, ', age: ', input$age))
    }
  )
  
}

shinyApp(ui = ui, server = server)