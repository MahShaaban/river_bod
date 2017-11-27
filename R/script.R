# load required libraries
library(tidyverse)
library(reshape2)
library(measurements)
library(leaflet)
library(htmltools)
library(lubridate)

source('R/functions.R')

# read the data
river_names = enc2utf8(c('황강2', '황강3', '황강5', '신반천', '토평천1', '토평천2', '창녕천'))
bod  <- read_csv('data/bod.csv')
score <- read_csv('data/score.csv')
md <- read_csv('data/river_metadata.csv') %>%
    mutate(river_names = river_names,
           north = to_decimal(north, '\\.', 'N'),
           east = to_decimal(east, '\\.', 'E'))

periods <- list(
    '1992:1996' = 1992:1996,
    '1997:2002' = 1997:2002,
    '2003:2012' = 2003:2012,
    '2013:2016' = 2013:2016
) %>%
    melt %>%
    setNames(c('year', 'period'))

# clean and merge
dat <- data_frame(year = rep(1992:2016, each = 12),           # make a year column
                  month = factor(rep(month.abb, times = 25),
                                 levels = month.abb)) %>%     # make a month column
    bind_cols(bod) %>%                                        # bind columns
    gather(river_id, bod, -year, -month) %>%                  # tidy data 
    full_join(score) %>%                                      # merge score data
    full_join(md) %>%                                         # merge metadata    
    full_join(periods)                                        # merge regulation periods

# summarize missing informations
## total number of missing values
dat %>%
    group_by(river_id) %>%
    summarise(missing = sum(is.na(bod))/n()) %>%
    ggplot(aes(x = river_id, y = missing)) +
    geom_col() +
    lims(y = c(0,1)) +
    theme_light() +
    labs(x = '',
         y = 'Percent of NA (%)',
         title = 'Proportion of missing data')
ggsave('figures/fig1.png', width = 5, height = 5)
    
## missing values by year
dat %>%
    group_by(period) %>%
    summarise(Missing = sum(is.na(bod))/n(),
              Available = 1 - Missing) %>%
    gather(key, value, -period) %>%
    ggplot(aes(x = '', y = value, fill = key, group = key)) +
    geom_col(width = 1) +
    coord_polar(theta = 'y') +
    facet_wrap(~period) +
    theme_void() +
    labs(fill = '',
         title = 'Total percent of missing data')
ggsave('figures/fig2.png', width = 5, height = 5)

# summarize distributions
## distribution of raw and log values
dat %>%
    ggplot(aes(bod)) +
    geom_histogram() +
    theme_light() +
    labs(x = 'BOD',
         y = 'Count',
         title = 'Distribution of BOD measurements')
ggsave('figures/fig3.png', width = 5, height = 5)

dat %>%
    ggplot(aes(log(bod+1))) +
    geom_histogram() +
    theme_light() +
    labs(x = 'BOD',
         y = 'Count',
         title = 'Distribution of log BOD measurements')
ggsave('figures/fig4.png', width = 5, height = 5)

## distribution by river
dat %>%
    ggplot(aes(x = river_id, y = bod)) +
    geom_boxplot() +
    theme_light() +
    theme(legend.position = 'none') +
    labs(x = '',
         y = 'BOD',
         title = 'Distribution of BOD per river')
ggsave('figures/fig5.png', width = 5, height = 5)

dat %>%
    ggplot(aes(x = river_id, y = log(bod + 1))) +
    geom_boxplot() +
    theme_light() +
    theme(legend.position = 'none') +
    labs(x = '',
         y = 'BOD',
         title = 'Distribution of log BOD per river')
ggsave('figures/fig6.png', width = 5, height = 5)

dat %>%
    select(river_id, bod, period) %>%
    na.omit() %>%
    ggplot(aes(x = river_id, y = bod)) +
    geom_boxplot(na.rm = TRUE) +
    theme_light() +
    facet_grid(.~period, scales = 'free_x', space = 'free_x') +
    theme(legend.position = 'none',
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(x = '',
         y = 'BOD',
         title = 'Distrivution of BOD per river over time')
ggsave('figures/fig7.png', width = 10, height = 5)

# average trends by year 
dat %>%
    group_by(river_id, period, year) %>%
    summarise(ave = mean(bod, na.rm = TRUE)) %>%
    ggplot(aes(x = year, y = ave, group = river_id, color = river_id)) +
    geom_line() +
    geom_vline(xintercept = c(1996, 2002, 2013), color = 'gray') +
    scale_x_continuous(breaks = c(1992,1996, 2002, 2013, 2016)) +
    theme_light() +
    labs(x = '',
         y = 'Average BOD',
         color = 'River Name',
         title = 'Average BOD over time')
ggsave('figures/fig8.png', width = 10, height = 5)

dat %>%
    group_by(river_id, period, year) %>%
    summarise(ave = mean(bod, na.rm = TRUE)) %>%
    ggplot(aes(x = year, y = ave, group = river_id, color = river_id)) +
    geom_smooth(method = 'loess', span = .5, na.rm = TRUE, se = FALSE) +
    geom_vline(xintercept = c(1996, 2002, 2013), color = 'gray') +
    scale_x_continuous(breaks = c(1992,1996, 2002, 2013, 2016)) +
    theme_light() +
    labs(x = '',
         y = 'Average BOD',
         color = 'River Name',
         title = 'Average BOD over time (LOESS smoothed)')
ggsave('figures/fig9.png', width = 10, height = 5)

dat %>%
    group_by(river_id, period, year) %>%
    summarise(ave = mean(bod, na.rm = TRUE)) %>%
    ggplot(aes(x = year, y = ave, group = river_id, fill = river_id)) +
    geom_area() +
    geom_vline(xintercept = c(1996, 2002, 2013), color = 'gray') +
    scale_x_continuous(breaks = c(1992,1996, 2002, 2013, 2016)) +
    theme_light() +
    labs(x = '',
         y = 'Total BOD',
         fill = 'River Name',
         title = 'Contribution of rivers to the total BOD')
ggsave('figures/fig10.png', width = 10, height = 5)

# average trends by month
dat %>%
    group_by(river_id, month) %>%
    summarise(ave = mean(bod, na.rm = TRUE)) %>%
    ggplot(aes(x = month, y = ave, group = river_id, color = river_id)) +
    geom_line() +
    theme_light() +
    labs(x = '',
         y = 'Average BOD',
         color = 'River Name',
         title = 'Average BOD per month')
ggsave('figures/fig11.png', width = 10, height = 5)

dat %>%
    group_by(river_id, month) %>%
    summarise(ave = mean(bod, na.rm = TRUE)) %>%
    ggplot(aes(x = month, y = ave, group = river_id, color = river_id)) +
    geom_smooth(method = 'loess', span = .5, na.rm = TRUE, se = FALSE) +
    theme_light() +
    labs(x = '',
         y = 'Average BOD',
         color = 'River Name',
         title = 'Average BOD per month')
ggsave('figures/fig12.png', width = 10, height = 5)

# map data to a map
content <- dat %>%
    group_by(river_id, period) %>%
    summarise(bod = round(mean(bod, na.rm = TRUE), 2)) %>%
    na.omit() %>%
    mutate(txt = paste(period, bod, sep = ' = '),
           txt = paste(txt, collapse = '<br />'),
           txt = paste(river_id, txt, sep = '<br />')) %>%
    ungroup() %>%
    select(txt) %>%
    unlist() %>%
    unique()

dat %>%
    select(river_id, score, category, north, east) %>%
    unique() %>%
    mutate(color = c(rep('lightgreen', 2), 'darkgreen', 'blue', rep('red', 3)),
           content = content) %>%
    leaflet() %>%
    addTiles() %>%
    addCircles(lng = ~ east,
               lat = ~ north,
               radius = ~ score * 20,
               fillOpacity = .9,
               color = ~ color,
               popup = ~content) %>%
    addLegend('topright',
              labels = ~unique(category),
              colors = ~unique(color))
