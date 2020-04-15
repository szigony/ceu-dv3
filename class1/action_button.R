# Load libraries
library(shiny)

# Source functions
source('class1/shiny_functions.R')

ui <- fluidPage(
  
  # weight / (height (in m)^2)
  tags$h1('BMI'),
  
  sliderInput(inputId = 'weight', label = 'Weight (kg)', min = 40, max = 200, value = 80, step = 1),
  sliderInput(inputId = 'height', label = 'Height (cm)', min = 80, max = 200, value = 180, step = 1),
  
  actionButton(inputId = 'go', label = 'Calculate'),
  
  tags$br(),
  tags$br(),
  textOutput('bmi')
  
)

server <- function(input, output) {
  
  observeEvent(input$go,
    {
      
      weight <- isolate(input$weight)
      height <- isolate(input$height)
      
      output$bmi <- renderText(
        {
          height <- height / 100
          
          bmi <- weight / height^2
          bmi_class <- get_bmi_by_index_number(bmi)
          
          return(paste0('BMI: ', round(bmi, 2), ', BMI class: ', bmi_class))
        }
      )
      
    }
  )
  
}

shinyApp(ui = ui, server = server)