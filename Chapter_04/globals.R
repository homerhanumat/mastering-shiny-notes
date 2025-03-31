# settings ----
table_bg_color <- "light-blue"
dashboard_skin <- "yellow"

# for the tutorial ----
app_intro <- HTML(glue::glue("
This app explores data from the 
<a href='https://www.cpsc.gov/Research--Statistics/NEISS-Injury-Data' 
target='_blank'>National 
Electronic Injury Surveillance System</a> (NEISS). 
NEISS records all accidents seen 
in a representative sample of hospitals in the United States.
(The data we have here is a subset of the overall data, so the
app won't take too long to load.)
"))

# graph y-axis tooltip ----
units_info <- HTML(glue::glue(
  "The default choice is for the y-axis of the graph to show an estimate of the 
  <em>rate per 10,000</em>,
  i.e.:  the number of accidents out of every ten thousand people of the 
  given age in the population.  The choice 'count' switches to an estimate of the
  total number itself.  (The 'count' choice can be misleading, as the sizes 
  of the age-groups vary.)"
))

# get data sets ----
if (!exists("injuries")) {
  injuries <- vroom::vroom("neiss/injuries.tsv.gz")
  products <- vroom::vroom("neiss/products.tsv")
  population <- vroom::vroom("neiss/population.tsv")
}

# count_top helper function ----
count_top <- function(df, var, n = 5) {
  df %>%
    mutate({{ var }} := fct_lump(fct_infreq({{ var }}), n = n)) %>%
    group_by({{ var }}) %>%
    summarise(n = as.integer(sum(weight)))
}