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
      filter(
        if (input$is_movie_select == 2) is_movie == is_movie else is_movie == input$is_movie_select,
        if (length(input$title_select) == 0) title == title else title %in% input$title_select
      ) %>% 
      distinct()
  })
  
  ### Filters
  possible_choices <- reactive({
    data %>% 
      subset(date >= Sys.Date() - input$last_x_days_slider) %>% 
      filter(if (input$is_movie_select == 2) is_movie == is_movie else is_movie == input$is_movie_select)
  })
  
  output$title_selection <- renderUI({
    selectInput(inputId = "title_select", label = h5("Title"), choices = sort(unique(possible_choices()$title)), multiple = TRUE)
  })

  output$is_movie <- renderUI({
    radioButtons(inputId = "is_movie_select", label = h5("TV Shows or Movies?"),
                 choices = c("TV Shows" = "No", "Movies" = "Yes", "Both" = 2), selected = 2)
  })

  ### Text Output
  # Last X Days
  output$last_x_days_title <- renderPrint({
    HTML(paste0("<p style='last-x-days-title'>Last ", input$last_x_days_slider, " Days at a Glance<br><b>",
                time_wasted(last_x_days()), "</b> watched - <b>", episodes_watched(last_x_days()), "</b> episodes - <b>",
                movies_watched(last_x_days()), "</b> movies"))
  })
  
  ### Overview
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
    if (nrow(last_x_days()) == 0) {
      plot(1, 1, col = "white")
      text(1, 1, "There's no data for the selected criteria.")
    } else {
      ggplotly(
        last_x_days_chart(last_x_days() %>% select(-genres) %>% distinct()),
        tooltip = c("text")
      ) %>% 
        layout(
          paper_bgcolor = "transparent",
          plot_bgcolor = "transparent"
        )
    }
  })
  
  # Last X Days by Genres
  output$last_x_days_by_genre <- renderPlotly({
    if (nrow(last_x_days()) == 0) {
      plot(1, 1, col = "white")
      text(1, 1, "There's no data for the selected criteria.")
    } else {
      ggplotly(
        last_x_days_by_genre(last_x_days()),
        tooltip = c("text")
      ) %>% 
        layout(
          paper_bgcolor = "transparent",
          plot_bgcolor = "transparent"
        )
    }
  })
  
}