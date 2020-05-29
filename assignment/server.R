### Calculations
data <- create_view_history()

# Count of episodes watched
count_episodes_watched <- n_distinct(data %>% filter(is_movie == "No") %>% select(title, episode))

# Count of TV shows
count_tv_shows <- n_distinct(data %>% filter(is_movie == "No") %>% select(title))

# Count of movies watched
count_movies_watched <- n_distinct(data %>% filter(is_movie == "Yes") %>% select(title))

### Server
server <- function(input, output) {
  
  output$table <- DT::renderDataTable({
    DT::datatable(
      data,
      options = list(
        processing = FALSE
      )
    )
  })
  
  output$tv_shows <- renderValueBox({
    valueBox(
      count_tv_shows, "Different TV Shows", icon = icon("tv"),
      color = "teal"
    )
  })
  
  output$episodes_watched <- renderValueBox({
    valueBox(
      count_episodes_watched, "Episodes Watched", icon = icon("glasses"),
      color = "light-blue"
    )
  })
  
  output$movies_watched <- renderValueBox({
    valueBox(
      count_movies_watched, "Movies Watched", icon = icon("video"),
      color = "aqua"
    )
  })
  
}