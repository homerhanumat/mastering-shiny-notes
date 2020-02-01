library(ggplot2)

histogram <- function(x1, x2, binwidth = 0.1, xlim = c(-3, 3)) {
  df <- data.frame(
    x = c(x1, x2),
    g = c(rep("x1", length(x1)), rep("x2", length(x2)))
  )
  
  ggplot(df, aes(x, fill = g)) +
    geom_histogram(binwidth = binwidth) +
    coord_cartesian(xlim = xlim)
}

t_test <- function(x1, x2) {
  test <- t.test(x1, x2)
  
  sprintf(
    "p value: %0.3f\n[%0.2f, %0.2f]",
    test$p.value, test$conf.int[1], test$conf.int[2]
  )
}

## use it like this:

random_data_1 <- rnorm(100, mean = 0, sd = 1)
random_data_2 <- rnorm(100, mean = 0.5, sd = 1)

histogram(
  x1 = random_data_1,
  x2 = random_data_2
)

t_test(
  x1 = random_data_1,
  x2 = random_data_2
)
