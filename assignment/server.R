### Data
data <- create_view_history()

### Server
server <- function(input, output) {
  
  ### Data related calculations
  # Last X Days
  last_x_days <- reactive({
    data %>% 
      select(date, title, episode, is_movie, runtime, genres) %>% 
      subset(date >= Sys.Date() - input$last_x_days_slider) %>% 
      distinct()
  })
  
  ### Filters
  output$title_selection <- renderUI({
    selectInput(inputId = "title_select", label = h4("Title"), choices = sort(unique(data$title)), multiple = TRUE)
  })
  
  ### Text Output
  # Last X Days
  output$last_x_days_title <- renderPrint({
    HTML(paste0("<p style='last-x-days-title'>Last ", input$last_x_days_slider, " Days at a Glance<br><b>",
                time_wasted(last_x_days()), "</b> watched - <b>", episodes_watched(last_x_days()), "</b> episodes - <b>",
                movies_watched(last_x_days()), "</b> movies"))
  })
  
  ### Dashboard
  # KPIs
  output$tv_shows <- renderValueBox({
    valueBox(
      tv_shows(data), "Different TV Shows", icon = icon("tv"),
      color = "teal"
    )
  })
  
  output$episodes_watched <- renderValueBox({
    valueBox(
      episodes_watched(data), "Episodes Watched", icon = icon("glasses"),
      color = "light-blue"
    )
  })
  
  output$movies_watched <- renderValueBox({
    valueBox(
      movies_watched(data), "Movies Watched", icon = icon("video"),
      color = "aqua"
    )
  })
  
  output$time_wasted <- renderValueBox({
    valueBox(
      time_wasted(data), "Spent on Netflix", icon = icon("clock"),
      color = "blue"
    )
  })
  
  # Last X Days at a Glance
  output$last_x_days_chart <- renderPlotly({
    ggplotly(
      last_x_days_chart(last_x_days() %>% select(-genres) %>% distinct()),
      tooltip = c("text")
    ) %>% 
      layout(
        paper_bgcolor = "transparent",
        plot_bgcolor = "transparent"
      )
  })
  
  # Last X Days by Genres
  output$last_x_days_by_genre <- renderPlotly({
    ggplotly(
      last_x_days_by_genre(last_x_days()),
      tooltip = c("text")
    ) %>% 
      layout(
        paper_bgcolor = "transparent",
        plot_bgcolor = "transparent"
      )
  })
  
}