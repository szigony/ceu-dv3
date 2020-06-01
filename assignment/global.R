##### Load libraries
library(shiny)
library(shinydashboard)
library(tidyverse)
library(tRakt)
library(lubridate)
library(ggplot2)
library(plotly)
library(data.table)
library(DT)

##### Shared theme elements for ggplot
my_theme <- theme(
  axis.text.x = element_text(angle = 65, vjust = 0.6),
  axis.title = element_blank(),
  axis.text.y = element_blank(),
  axis.line.x = element_line(color = "gray84"),
  panel.grid.major.y = element_line(color = "gray84"),
  panel.grid.minor.y = element_line(color = "gray84"),
  panel.grid.major.x = element_blank(),
  panel.grid.minor.x = element_blank(),
  panel.background = element_blank(),
  plot.background = element_blank()
)

##### Create view history
create_view_history <- function() {
  
  ### Netflix viewing history
  # Load and transform Netflix data
  season_types <- c("Season", "Episode", "Chapter", "Part", "Series", "Volume")
  
  netflix_data <- read.csv("data/NetflixViewingHistory.csv") %>% 
    mutate(colon_count = str_count(Title, ":")) %>% 
    separate(Title, c("title", "subtitle", "season", "episode"), sep = ":") %>% 
    mutate(
      episode = ifelse(colon_count == 2, season, episode),
      season = ifelse(colon_count == 2, subtitle, season),
      episode = ifelse(!grepl(paste(season_types, collapse = "|"), season), paste0(season, ": ", episode), episode),
      season = ifelse(!grepl(paste(season_types, collapse = "|"), season), subtitle, season),
      subtitle = ifelse(grepl(paste(season_types, collapse = "|"), subtitle), NA, subtitle),
      episode = ifelse(colon_count == 0, NA, episode),
      is_movie = ifelse(is.na(season), "Yes", "No"),
      date = Date,
      title = ifelse(!is.na(subtitle), paste0(title, ":", subtitle), title)
    ) %>% 
    select(-c(colon_count, Date, subtitle))
  
  ### trakt datasets (http://jemus42.github.io/tRakt/index.html)
  # Get view history from trakt
  trakt_history <- user_history(user = "szigony", type = "shows", limit = 20000) %>% 
    select(trakt_id = trakt, imdb_id = imdb, title) %>% 
    rbind(
      user_history(user = "szigony", type = "movies", limit = 20000) %>% 
        select(trakt_id = trakt, imdb_id = imdb, title)
    ) %>% 
    distinct()
  
  ### Join Netflix and trakt datasets, include additional information from trakt
  view_history <- netflix_data %>% 
    inner_join(trakt_history, by = "title")
  
  show_ids <- view_history %>% filter(is_movie == "No") %>% select(trakt_id) %>% distinct()
  movie_ids <- view_history %>% filter(is_movie == "Yes") %>% select(trakt_id) %>% distinct()
  
  show_summary <- shows_summary(show_ids$trakt_id, extended = "full") %>% 
    select(trakt_id = trakt, runtime, language, genres) %>% 
    rbind(
      movies_summary(movie_ids$trakt_id, extended = "full") %>% 
        select(trakt_id = trakt, runtime, language, genres)
    ) %>% 
    unnest(genres)
  
  view_history <- view_history %>% 
    inner_join(show_summary, by = "trakt_id") %>% 
    mutate(date = mdy(date)) %>% 
    select(-c(trakt_id, imdb_id)) %>% 
    distinct()
  
  ### Remove unnecessary variables
  rm(netflix_data, show_summary, trakt_history, season_types, show_ids, movie_ids) 

  ### Return the created table
  return(view_history)
  
}

##### Calculations
# TV shows
tv_shows <- function(data) {
  return(n_distinct(data %>% filter(is_movie == "No") %>% select(title)))
}

# Episodes watched
episodes_watched <- function(data) {
  return(n_distinct(data %>% filter(is_movie == "No") %>% select(title, episode)))
}

# Movies watched
movies_watched <- function(data) {
  return(n_distinct(data %>% filter(is_movie == "Yes") %>% select(title)))
}

# Time wasted
time_wasted <- function(data) {
  overall_time <- seconds_to_period(
    (data %>% 
       select(title, episode, runtime) %>% 
       distinct() %>% 
       select(-c(episode, title)) %>% 
       summarise_all(list(sum)) %>% 
       pull(1)
     )*60)
  
  return(paste0(lubridate::day(overall_time), "d ", lubridate::hour(overall_time), "H ", lubridate::minute(overall_time), "M"))
}

##### Charts
### Overview
# Last X Days at a Glance
last_x_days_chart <- function(data) {
  data <- data %>% group_by(date) %>% count(date)
  max_data <- max(data$n)
  mean_data <- mean(data$n)
  
  p <- ggplot(data, aes(x = date, y = n, text = paste0("Watched episodes: <b>", n, "</b>"))) +
    geom_point(size = 6, color = "#00C1A7") +
    scale_x_date(date_labels = "%m/%d", date_breaks = "1 day") +
    geom_text(aes(label = n), color = "white", fontface = "bold", size = 4) +
    geom_hline(yintercept = mean_data, color = "firebrick2") +
    ylim(0, max_data) +
    my_theme +
    theme(
      axis.ticks.y = element_blank()
    )
  
  return(p)
}

# Last X Days by Genre
last_x_days_by_genre <- function(data) {
  data <- data %>% 
    group_by(genres) %>% 
    summarise(movies_count = uniqueN(title[is_movie == "Yes"]), show_count = uniqueN(title[is_movie == "No"]),
              episode_count = uniqueN(episode[is_movie == "No"]), total_count = uniqueN(title))
  
  p <- ggplot(data, aes(fill = genres, x = reorder(genres, total_count), y = total_count,
                        text = paste0("<b>", genres, "</b><br>", episode_count, " episodes<br>", 
                                      show_count, " shows<br>", movies_count, " movies"))) +
    geom_bar(stat = "identity", show.legend = FALSE) +
    coord_flip() +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      panel.background = element_blank(),
      plot.background = element_blank(),
      legend.position = "none"
    )
  
  return(p)
}

### Statistics
# Shared Data
shared_stats_data <- function(data) {
  data <- data %>% 
    select(date, title, episode, is_movie) %>% 
    distinct() %>% 
    group_by(date, is_movie) %>% 
    count(is_movie) %>% 
    ungroup()
  
  return(data)
}

# Total Number of Views
total_no_of_views <- function(data) {
  data <- shared_stats_data(data) %>% 
    mutate(
      movie_count = ifelse(is_movie == "Yes", n, 0),
      show_count = ifelse(is_movie == "No", n, 0)
    ) %>% 
    group_by(is_movie) %>% 
    mutate(cum_show = cumsum(show_count), cum_movie = cumsum(movie_count)) %>% 
    ungroup() %>% 
    select(date, cum_show, cum_movie) %>% 
    gather("movie_or_show", "cum_sum", -date) %>% 
    mutate(movie_or_show = ifelse(movie_or_show == "cum_show", "TV Show", "Movie"))
  
  p <- ggplot(data, aes(x = date, y = cum_sum, fill = movie_or_show, text = paste0("Date: <b>", date, "</b><br>Type: <b>",
                                                                                   movie_or_show, "</b><br>Total Views: <b>",
                                                                                   cum_sum, "</b>"))) +
    geom_col() +
    scale_x_date(date_labels = "%m/%d", date_breaks = "1 week") +
    my_theme +
    theme(
      axis.ticks = element_blank(),
      legend.title = element_blank(),
      legend.position = "top"
    )
  
  return(p)
}

# Daily Views
daily_views <- function(data) {
  data <- shared_stats_data(data) %>% 
    mutate(is_movie = ifelse(is_movie == "Yes", "Movie", "TV Show"))
  
  p <- ggplot(data, aes(x = date, y = n, fill = is_movie, text = paste0("Date: <b>", date, "</b><br>Type: <b>", is_movie,
                                                                        "</b><br>Count: <b>", n, "</b>"))) +
    geom_col() +
    scale_x_date(date_labels = "%m/%d", date_breaks = "1 week") +
    my_theme +
    theme(
      axis.ticks = element_blank(),
      legend.title = element_blank(),
      legend.position = "top"
    )
  
  return(p)
}

##### Tables
# Most Popular TV Shows
most_popular_tv_shows <- function(data, top_n) {
  data <- data %>% 
    filter(is_movie == "No") %>% 
    select(title, episode) %>% 
    distinct() %>% 
    group_by(title) %>% 
    count() %>% 
    ungroup() %>% 
    arrange(-n) %>% 
    top_n(top_n)
}

# Most Popular Movies
most_popular_movies <- function(data, top_n) {
  data %>% 
    filter(is_movie == "Yes") %>% 
    select(title) %>% 
    distinct() %>% 
    top_n(top_n)
}