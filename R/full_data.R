library(tidyverse)
library(readxl)
library(leaflet)
library(webshot)
library(mapview)
source('R/functions.R')

wqi <- read_excel('data/WQI_classification.xlsx', skip = 1) %>%
    setNames(c('region', 'korean_name', 'river_name', 'north', 'east', 'wqi', 'bod','toc', 'tp')) %>%
    mutate(north = to_decimal(north, pattern = "º |'|\\.|\""),
           east = to_decimal(east, pattern = "º |'|\\.|\""))

color = data_frame(bod = c('Ia', 'Ib', 'II', 'III', 'IV', 'V', 'VI'),	
                   color = c('blue', 'green', 'yellow', 'orange', 'pink', 'red', 'black'))
wqi %>%
    left_join(color) %>%
    leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addCircles(lng = ~ east,
               lat = ~ north,
               radius = 1000,
               fillOpacity = .9,
               color = ~color,
               popup = ~river_name) %>%
    addLegend('topright',
              labels = color$bod,
              colors = color$color)

color = data_frame(toc = c('Ia', 'Ib', 'II', 'III', 'IV', 'V', 'VI'),	
                   color = c('blue', 'green', 'yellow', 'orange', 'pink', 'red', 'black'))

wqi %>%
    left_join(color) %>%
    leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addCircles(lng = ~ east,
               lat = ~ north,
               radius = 1000,
               fillOpacity = .9,
               color = ~color) %>%
    addLegend('topright',
              labels = color$toc,
              colors = color$color)

color = data_frame(tp = c('Ia', 'Ib', 'II', 'III', 'IV', 'V', 'VI'),	
                   color = c('blue', 'green', 'yellow', 'orange', 'pink', 'red', 'black'))

wqi %>%
    left_join(color) %>%
    leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addCircles(lng = ~ east,
               lat = ~ north,
               radius = 1000,
               fillOpacity = .9,
               color = ~color,
               popup = ~river_name) %>%
    addLegend('topright',
              labels = color$tp,
              colors = color$color)
    

color = data_frame(wqi = c('Excellent', 'Good', 'Fair', 'Marginal', 'Poor'),
                   color = c('blue', 'yellow', 'orange', 'pink', 'red'))

wqi %>%
    left_join(color) %>%
    leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addCircles(lng = ~ east,
               lat = ~ north,
               radius = 1000,
               fillOpacity = .9,
               color = ~color) %>%
    addLegend('topright',
              labels = color$wqi,
              colors = color$color)

wqi %>%
    mutate(id = row_number()) %>%
    leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addLabelOnlyMarkers(lng = ~ east,
                     lat = ~ north,
                     label = ~as.character(id),
                     labelOptions = list(noHide=TRUE,
                                         textOnly = TRUE,
                                         direction = 'top',
                                         textsize = '12px')) %>%
    addLegend('topright',
              labels = paste(~korean_name, ~id),
              colors = rep('red', 84))
wqi %>%
    mutate(id = as.character(row_number())) %>%
    select(id, korean_name) -> wqi

periods <- list(
    '1992:1995' = 1992:1995,
    '1996:2001' = 1996:2001,
    '2002:2011' = 2002:2011,
    '2012:2016' = 2012:2016
) %>%
    melt %>%
    setNames(c('year', 'period'))

bod <- read_excel('data/water_quality.xlsx',
                  col_types = 'numeric') %>%
    select(-1, -2) %>%
    mutate(year = rep(1992:2016, each = 12),
           month = factor(rep(month.abb, times = 25),
                          levels = month.abb)) %>%
    gather(korean_name, bod, -month, -year) %>%
    na.omit()

bod %>%
    left_join(wqi) %>%
    left_join(periods) %>%
    mutate(id = factor(id, levels = 1:84)) %>%
    ggplot(aes(x = id, y = bod)) +
    geom_boxplot() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 5)) +
    facet_wrap(~period, ncol = 1, scales = 'free_y') +
    labs(y = 'BOD', x = 'River ID')
ggsave('figures/bod_boxplot.png')

sheets <- c('BOD', 'COD', 'TOC', 'TN', 'TP', 'SS', 'CHL a', 'DO', 'EC', 'pH', 'TEMP')
names(sheets) <- sheets
map(sheets, function(x) {
    read_excel('data/water_quality.xlsx',
               col_types = 'numeric',
               sheet = x) %>%
        select(-1, -2) %>%
        mutate(year = rep(1992:2016, each = 12),
               month = factor(rep(month.abb, times = 25),
                              levels = month.abb)) %>%
        gather(korean_name, val, -month, -year) %>%
        na.omit() %>%
        left_join(wqi) %>%
        left_join(periods) %>%
        mutate(id = factor(id, levels = 1:84)) %>%
        ggplot(aes(x = id, y = val)) +
        geom_boxplot() +
        theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 5)) +
        facet_wrap(~period, ncol = 1, scales = 'free_y') +
        labs(y = x, x = 'River ID')
    ggsave(filename = paste('figures/', x, '_boxplot.png', sep = ''))
})
