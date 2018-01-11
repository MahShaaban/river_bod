to_decimal <- function(dms, pattern) {
    df <- stringr::str_split(dms, pattern, simplify = TRUE)[, 1:4]
    df <- as.data.frame.matrix(df, stringsAsFactors = FALSE) %>%
        setNames(c('degree', 'minute', 'second', 'msecond')) %>%
        mutate(deg_min_sec = paste(degree, ' ', minute, ' ', second, '.', msecond, sep = ''))
    as.numeric(measurements::conv_unit(df$deg_min_sec, 'deg_min_sec', 'dec_deg'))
    }
