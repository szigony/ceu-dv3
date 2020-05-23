# Load libraries
library(tidyverse)

# Set working directory
setwd("C:/Users/szige/Desktop/CEU/2019-2020 Spring/Data Visualization 3/ceu-dv3/assignment")

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

# title.basics.tsv.gz dataset from https://www.imdb.com/interfaces/
imdb_basics <- read_tsv("data/imdb_basics.tsv") %>% 
  inner_join(netflix_data %>% select(title), by = c("primaryTitle" = "title")) %>% 
  distinct() %>% 
  select(title = primaryTitle, genres) %>% 
  group_by(title) %>% 
  mutate(genres = paste0(genres, collapse = ",")) %>% 
  ungroup()
