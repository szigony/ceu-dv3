### Data
data <- create_view_history()

### Server
server <- function(input, output) {
  
  ### Data related calculations
  # Last X Days ### TODO make reactive
  last_x_days <- data %>% 
    select(date, title, episode, is_movie, runtime) %>% 
    subset(date >= Sys.Date() - 30) %>% 
    distinct()
  
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
  
  # Last X days at a glance
  output$last_x_days_chart <- renderPlotly({
    ggplotly(
      last_x_days_chart(last_x_days),
      tooltip = c("text")
    ) %>% 
      layout(
        title = list(
          text = paste0("Last 30 Days at a Glance<br><sup>", 
                        time_wasted(last_x_days), " watched - ",
                        episodes_watched(last_x_days), " episodes - ",
                        movies_watched(last_x_days), " movies</sup>"),
          x = 0, y = 0.95
        ),
        paper_bgcolor = "transparent",
        plot_bgcolor = "transparent"
      )
  })
  
}