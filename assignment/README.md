# Analysis of a viewer's behavior on Netflix
Home Assignment for *Data Visualization 3: Data Visualization in Production with Shiny* @ CEU, Budapest, 2020 Spring trimester.

#### Table of contents

- [About the data](#about-the-data)
- [Functions](#functions)
  - [Data-related](#data-related)
  - [Calculations](#calculations)
  - [Charts](#charts)
  - [Tables](#tables)
- [Styling](#styling)
- [Google Analytics](#google-analytics)
- [Application](#application)
- [Shinyproxy](#shinyproxy)
- [Recommendations](#recommendations)

## About the data

- The initial dataset was downloaded from [Netflix](https://www.netflix.com/browse). Anyone with an account can navigate to *Account* < *Profile* (you can pull this separately for each profile on the same account) < *Viewing activity* - Click *View* < *Download all*. This is a `.csv` file that contains information about the title of the TV show/movie, and if it's a TV show, the number of the season and the title of the episode. There's also a column for the date you watched an item.
- Since this wouldn't be enough for a meaningful analysis, I enriched the data by leveraging [trakt.tv](http://trakt.tv/)'s API via jemus42's [tRakt](https://github.com/jemus42/tRakt) package. Trakt is a tracking page for TV shows and movies, and luckily I've been heavily using it, so there's almost a 1:1 relationship with my Netflix viewing history (some titles unfortunately fall out when joining). This way I was able to add the genres, the runtime and the language for each title.

## Functions

> All of the functions can be found in the **[global.R](https://github.com/szigony/ceu-dv3/blob/master/assignment/global.R)** file.

### Data-related

#### `netflix_data`

#### `create_view_history`

### Calculations

#### `tv_shows`

#### `episodes_watched`

#### `movies_watched`

#### `time_wasted`

#### `percentage_match`

### Charts

##### `my_theme`

#### `last_x_days_by_genre`

##### `shared_stats_data`

##### `shared_cum_sum`

#### `total_no_of_views`

#### `daily_views`

##### `shared_count`

#### `number_of`

#### `comparison_chart`

### `Tables`

#### `most_popular_tv_shows`

#### `most_popular_movies`

## Styling



## Google Analytics



## Application



## Shinyproxy



## Recommendations

