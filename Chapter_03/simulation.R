library(mosaic) # brings in ggplot2 as well

histogram <- function(x1, x2, binwidth = 0.1, xlim = c(-3, 3)) {
  df <- data.frame(
    x = c(x1, x2),
    g = c(rep("x1", length(x1)), rep("x2", length(x2)))
  )
  
  ggplot(df, aes(x, fill = g)) +
    geom_histogram(binwidth = binwidth) +
    coord_cartesian(xlim = xlim)
}

numerical_summary <- function(x1, x2) {
  n1 <- length(x1)
  n2 <- length(x2)
  df <- data.frame(
    sample_number = c(rep("1", n1), rep("2", times = n2)),
    sample_data = c(x1, x2),
    stringsAsFactors = FALSE
  )
  df %>% 
    mosaic::favstats(sample_data ~ sample_number, data = .) %>% 
    select(sample_number, min, mean, max, n)
}

## use it like this:

random_data_1 <- rnorm(100, mean = 0, sd = 1)
random_data_2 <- rnorm(100, mean = 0.5, sd = 1)

histogram(
  x1 = random_data_1,
  x2 = random_data_2
)

numerical_summary(
  x1 = random_data_1,
  x2 = random_data_2
)
