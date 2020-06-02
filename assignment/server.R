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
  
  # Date Range
  date_range <- reactive({
    data %>% 
      subset(date >= format(input$date[1]) & date <= format(input$date[2])) %>% 
      filter(
        if (input$is_movie_select == 2) is_movie == is_movie else is_movie == input$is_movie_select,
        if (length(input$title_select) == 0) title == title else title %in% input$title_select
      )
  })
  
  # Uploaded file
  history_to_compare <- reactive({
    file <- input$file
    return(netflix_data(csv_file = file$datapath))
  })

  # Netflix Date Range
  date_range_me <- reactive({
    netflix_data() %>% 
      mutate(date = mdy(date)) %>% 
      subset(date >= format(input$date[1]) & date <= format(input$date[2])) %>% 
      filter(
        if (length(input$title_select) == 0) title == title else title %in% input$title_select
      )
  })
  
  # Uploaded Date Range
  date_range_compare <- reactive({
    history_to_compare() %>% 
      mutate(date = mdy(date)) %>% 
      subset(date >= format(input$date[1]) & date <= format(input$date[2])) %>% 
      filter(
        if (length(input$title_select) == 0) title == title else title %in% input$title_select
      )
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
    HTML(paste0("<p class='last-x-days-title'>Last ", input$last_x_days_slider, " Days at a Glance<br><b>",
                time_wasted(last_x_days()), "</b> watched - <b>", episodes_watched(last_x_days()), "</b> episodes - <b>",
                movies_watched(last_x_days()), "</b> movies"))
  })
  
  # Disclaimer
  output$disclaimer <- renderUI({
    HTML("<p class='disclaimer'><i>Disclaimer:</i> The view history was downloaded from 
        Netflix. Additional information (e.g. genres, runtime) was added via trakt.tv's API.</p>")
  })
  
  # Netflix History File Upload
  output$netflix_history_file <- renderUI({
    HTML("<p class='how-to-download'>You can download your history from Netflix by navigating to 
         <i>Account</i> < <i>Profile</i> < <i>Viewing activity</i>. Click <b>Download all</b> on the bottom of the page.</p>")
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
      )
    }
  })
  
  ### Statistics
  # Total Number of Views
  output$total_no_of_views <- renderPlotly({
    ggplotly(
      total_no_of_views(date_range()),
      tooltip = c("text")
    )
  })
  
  # Most Popular TV Shows
  output$popular_tv_shows <- DT::renderDataTable({
    DT::datatable(
      most_popular_tv_shows(date_range(), input$show_top),
      colnames = c("TV Show", "Episodes"),
      options = list(
        paging = FALSE,
        searching = FALSE
      )
    )
  })
  
  # Most Popular Movies
  output$popular_movies <- DT::renderDataTable({
    DT::datatable(
      most_popular_movies(date_range(), input$show_top),
      colnames = c("Movie"),
      options = list(
        paging = FALSE,
        searching = FALSE
      )
    )
  })
  
  # Daily Views
  output$daily_views <- renderPlotly({
    ggplotly(
      daily_views(date_range()),
      tooltip = c("text")
    )
  })
  
  ### Comparison
  # Match
  output$match <- renderInfoBox({
    if (is.null(input$file)) {
      infoBox(
        "Match", "?", icon = icon("percent"), color = "light-blue", fill = TRUE
      )
    } else {
      infoBox(
        "Overall Match", percentage_match(netflix_data(), history_to_compare()), icon = icon("percent"), color = "green", fill = TRUE
      ) 
    }
  })

  # # of TV Shows
  output$number_of_tv_shows <- renderPlotly({
    ggplotly(
      number_of(date_range_me(), date_range_compare(), movie = "No"),
      tooltip = c("text"), height = 170
    ) %>% 
      layout(showlegend = FALSE)
  })
  
  # # of Movies
  output$number_of_movies <- renderPlotly({
    ggplotly(
      number_of(date_range_me(), date_range_compare()),
      tooltip = c("text"), height = 170
    ) %>% 
      layout(showlegend = FALSE)
  })
  
  # Comparison of Total # of TV Show Views
  output$compare_views <- renderPlotly({
    if (is.null(input$file)) {
      plot(1, 1, col = "white")
      text(1, 1, "Please upload a file in the sidebar.")
    } else {
      ggplotly(
        comparison_chart(netflix_data(), history_to_compare(), input$date[1], input$date[2]),
        tooltip = c("text"), height = 290
      )
    }
  })
  
}