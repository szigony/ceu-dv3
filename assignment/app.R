# Load libraries
library(shiny)
library(shinythemes)
library(DT)
library(tidyverse)

ui <- navbarPage(
  
  'My Netflix Behavior',
  theme = shinytheme('united'),
  
  tabPanel(
    'Home',
    DT::dataTableOutput('data')
  )

)

server <- function(input, output) {
  
  netflix_data <- read.csv('data/NetflixViewingHistory.csv') %>% 
    separate(Title, c('title', 'season', 'episode'), ':') %>% 
    mutate(
      is_movie = ifelse(is.na(season), 'Yes', 'No')
    )
  
  output$data <- DT::renderDataTable(
    {
      netflix_data
    }
  )
  
}

shinyApp(ui = ui, server = server)