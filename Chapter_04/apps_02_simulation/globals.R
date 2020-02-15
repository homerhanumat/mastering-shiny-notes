## ordinary R code to make a graph and numerical summary on simulated data


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
