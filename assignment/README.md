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
  - [Overview](#overview)
  - [Statistics](#statistics)
  - [Comparison](#comparison)
- [Shinyproxy](#shinyproxy)
- [Recommendations](#recommendations)

## About the data

- The initial dataset was downloaded from [Netflix](https://www.netflix.com/browse). Anyone with an account can navigate to *Account* < *Profile* (you can pull this separately for each profile on the same account) < *Viewing activity* - Click *View* < *Download all*. This is a `.csv` file that contains information about the title of the TV show/movie, and if it's a TV show, the number of the season and the title of the episode. There's also a column for the date you watched an item.
- Since this wouldn't be enough for a meaningful analysis, I enriched the data by leveraging [trakt.tv](http://trakt.tv/)'s API via jemus42's [tRakt](https://github.com/jemus42/tRakt) package. Trakt is a tracking page for TV shows and movies, and luckily I've been heavily using it, so there's almost a 1:1 relationship with my Netflix viewing history (some titles unfortunately fall out when joining). This way I was able to add the genres, the runtime and the language for each title.

## Functions

> All of the functions can be found in the **[global.R](https://github.com/szigony/ceu-dv3/blob/master/assignment/global.R)** file.

### Data-related

#### `netflix_data`

This function loads the data extracted from Netflix and performs transformations to create a tidy dataset. Even though the text is separated by a colon, there are titles such as Narcos: Mexico that make it a bit more difficult to process the data. I'm also adding an `is_movie` binary variable here to help further analysis.

#### `create_view_history`

Enriches the Neflix data with my personal history from *trakt.tv*. Returns a table with the viewing history, as well as the runtime, language and genres for each title.

### Calculations

#### `tv_shows`

Calculates the number of distinct TV show titles in the dataset.

#### `episodes_watched`

Calculates the number of distinct TV show titles and episode titles in the dataset.

#### `movies_watched`

Calculates the number of distinct movie titles in the dataset.

#### `time_wasted`

Based on the `runtime`, calculates how much time was spent on Netflix.

#### `percentage_match`

Calculates the intersection of the baseline viewing history (mine) and the uploaded file basedon on distinct titles.

### Charts

##### `my_theme`

I created a custom theme for `ggplot2` that hides the background, some of the axis texts, gives an angle to the x axis, and sets a lighter color for the grids.

#### `last_x_days_chart`

Creates a point diagram for the last X days based on how many titles were watched. Adds a line for the average as a benchmark.

#### `last_x_days_by_genre`

Creates a bar chart with flipped axes to show which were the most popular genres for the last N days. A title can belong to multiple genres.

##### `shared_stats_data`

Creates a shared dataset with counts for each day grouped by `is_movie`.

##### `shared_cum_sum`

Creates a dataset with cumulated amounts for the whole period.

#### `total_no_of_views`

A bar chart for the cumulated values for the whole period to highlight patterns in viewing history.

#### `daily_views`

A stacked bar chart for the daily views for the selected date range by `is_movie`.

##### `shared_count`

Returns a shared dataset with counts by `is_movie`, **regardless** of the date.

#### `number_of`

Creates a bar chart for how many TV shows/movies were watched in total in the selected date range. This is used for comparing the baseline with the uploaded file.

#### `comparison_chart`

Returns a bar chart based on [`shared_cum_sum`](#shared_cum_sum) to compare the baseline with the uploaded file.

### Tables

#### `most_popular_tv_shows`

Returns a table with the N most popular TV shows in the selected period.

#### `most_popular_movies`

Returns a table with the N most popular movies in the selected period.

## Styling

> The custom CSS that was applied can be found in the **[www/style.css](https://github.com/szigony/ceu-dv3/blob/master/assignment/www/style.css)** file.

## Google Analytics

> Google Analytics tracking was added to the header of the page in **[ui.R](https://github.com/szigony/ceu-dv3/blob/master/assignment/ui.R)** by including the **[google-analytics.html](https://github.com/szigony/ceu-dv3/blob/master/assignment/google-analytics.html)** file.

## Application

> The application is available **[here](https://szigeti-patrik.shinyapps.io/netflix-behavior/)**.

I applied `conditionalPanel`s for the sidebars to only show filters/inputs where they are relevant or affect the visualizations.

### Overivew

**Sidebar:**
- Title (`selectInput` with titles that meet all selected criteria)
- Last Days Shown (`sliderInput`)
- TV Shows or Movies? (`radioButtons`)

+ Disclaimer with `htmlOutput`

The Overview tab focuses on KPIs for the whole dataset, these are all `valueBox`es:
- Number of different TV Shows
- Episodes Watched
- Movies Watched
- Time Spent on Netflix

And looking at a trend of the last N number of days at a glance with `plotly` charts (idea from [htmlwidgets.org](http://www.htmlwidgets.org/)), as well as the genres of these titles.

### Statistics

**Sidebar:**
- Title
- Top Views Shown (`numericInput`)
- Date Range (`dateRangeInput`)
- TV Shows or Movies?

+ Disclaimer

The Statistics tab shows two `plotly` charts, one with the cumulative number of views within the period to look at trending and regularities in the data, and one with the number of daily views, both stacked by the `is_movie` filter. There are also two `DT` data tables with the N most popular TV shows and movies. For the TV shows, you can also see the number of episodes watched in the period. All visuals are reacting to the inputs in the sidebar.

### Comparison

**Sidebar:**
- Title
- Date Range
- Upload Your Netflix History (`fileInput`)

+ Disclaimer

The Comparison tab allows the user to upload their own Netflix viewing history, and compare it against mine (refered to as Baseline). Visuals are only calculated once a file has been uploaded.

There's a KPI showing the overall match in percentage based on the intersection of unique titles (`infoBox`) on the top left corner. Next to it are two bar charts comparing the number of unique TV shows and movies that were watched in the date range. The "Comparison of All Time Total # of TV Show Views" shows a cumulative view of the number of TV show episodes compared to the baseline by date.

## Shinyproxy

In order to create the Docker image, I had to run a couple of commands from the terminal:

- I installed the following packages: `shinydashboard`, `tidyverse`, `plotly`, `DT`:

```
sudo R -e "devtools::with_libpaths(new = '/usr/local/lib/R/site-library', install.packages(c('shinydashboard', 'tidyverse', 'plotly', 'DT'), repos='https://cran.rstudio.com/'))"
```

- And an additional package from GitHub:

```
sudo Rscript -e "library(devtools);with_libpaths(new = '/usr/local/lib/R/site-library', install_github('jemus42/tRakt', upgrade_dependencies = FALSE))"
```

For my starting point, I used the [rocker/shiny-verse](https://hub.docker.com/r/rocker/shiny-verse) image from DockerHub. This was my final **Dockerfile**:

```
FROM rocker/shiny-verse

RUN installGithub.r jemus42/tRakt
RUN install2.r shinydashboard tidyverse plotly DT

RUN mkdir /app
COPY *.R /app/

EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/app', port = 3838, host = '0.0.0.0')"]
```

## Recommendations

