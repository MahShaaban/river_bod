to_decimal <- function(dms, pattern, direction) {
    df <- stringr::str_split(dms, pattern, simplify = TRUE)[, 1:3]
    df <- as.data.frame.matrix(df, stringsAsFactors = FALSE) %>%
        setNames(c('degree', 'minute', 'second')) %>%
       dplyr:: mutate(degree = as.numeric(degree)/1,
                      minute = as.numeric(minute) / 60,
                      second = as.numeric(second) / 360)
    dec <- with(df, degree + minute + second)
    
    dec
}

to_decimal(md$north, '\\.', 'N')
undebug(to_decimal)
