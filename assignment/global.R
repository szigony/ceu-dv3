### Load libraries
library(shiny)
library(shinydashboard)
library(tidyverse)
library(tRakt)
library(lubridate)

### Create view history
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
      date = Date
    ) %>% 
    select(-c(colon_count, Date))
  
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
