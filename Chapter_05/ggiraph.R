library(vroom)
library(tidyverse)
library(ggiraph)

## first, set working directory to this file location

injuries <- vroom::vroom("neiss/injuries.tsv.gz")
injuries

products <- vroom::vroom("neiss/products.tsv")
products

population <- vroom::vroom("neiss/population.tsv")
population

selected <- injuries %>% filter(prod_code == 1842)

selected %>% count(diag, wt = weight, sort = TRUE)
## compare with unweighted tally:
selected %>% count(diag, sort = TRUE)


selected %>% count(body_part, wt = weight, sort = TRUE)


selected %>% count(location, wt = weight, sort = TRUE)

summary <- selected %>% 
  count(age, sex, wt = weight)
summary

summary %>% 
  ggplot(aes(age, n, colour = sex)) + 
  geom_line() + 
  labs(y = "Estimated number of injuries")

summary <- selected %>% 
  count(age, sex, wt = weight) %>% 
  left_join(population, by = c("age", "sex")) %>% 
  mutate(rate = n / population * 1e4) %>% 
  mutate(tip = glue::glue(
    "age: {age}<br>rate: {round(rate, 2)}<br>sex: {sex}"
  ))

summary$tip <- 
  HTML(glue::glue_data(summary,
    "age: {summary$age}<br>rate: {round(summary$rate, 2)}<br>sex: {summary$sex}"
    )
  )

summary <- mutate(summary, tip =
  glue::glue(
  "age: {age}<br>rate: {round(rate, 2)}<br>sex: {sex}"
)
)

gg_point <-
  summary %>% 
  ggplot(aes(age, rate, colour = sex)) + 
  geom_line(na.rm = TRUE) + 
  labs(y = "Injuries per 10,000 people") +
  geom_point_interactive(aes(tooltip = tip))
girafe(ggobj = gg_point)
