# show/hide tutorail ----
## ensure totorial button is present only on the home tab
observeEvent(input$tabs, {
  if (input$tabs == "tables") {
    show("help")
  } else {
    hide("help")
  }
})

# selected reactive ----
selected <- reactive(injuries %>% filter(prod_code == input$code))

# table outputs ----
output$diag <- renderTable(count_top(selected(), diag), width = "100%")
output$body_part <- renderTable(count_top(selected(), body_part), width = "100%")
output$location <- renderTable(count_top(selected(), location), width = "100%")
# >> table

# summary reactive ----
summary <- reactive({
  selected() %>%
    count(age, sex, wt = weight) %>%
    left_join(population, by = c("age", "sex")) %>%
    mutate(rate = n / population * 1e4)
})

# plot output ----
output$age_sex <- renderPlotly({
  if (input$y == "count") {
    p <-
      summary() %>%
      mutate(tip = glue::glue(
        "age: {age}<br>accidents: {round(n, 0)}<br>sex: {sex}"
      )) %>%
      ggplot(aes(age, n, colour = sex, text = tip, group = sex)) +
      geom_line() +
      labs(y = "Estimated number of accidents") +
      theme_grey(15)
  } else {
    p <-
      summary() %>%
      mutate(tip = glue::glue(
        "age: {age}<br>rate: {round(rate, 2)}<br>sex: {sex}"
      )) %>%
      ggplot(aes(age, rate, colour = sex, text = tip, group = sex)) +
      geom_line(na.rm = TRUE) +
      # geom_point(na.rm = TRUE) +
      labs(y = "Accidents per 10,000 people") +
      theme_grey(15)
  }
  ggplotly(p, tooltip = "text") %>%
    plotly::config(displayModeBar = FALSE)
})
# >> plot output


# narrative output ----
output$narrative <- renderText({
  input$story
  selected() %>%
    pull(narrative) %>%
    sample(1)
})
# << narrative

# start introjs observer ----
observeEvent(
  input$help,
  introjs(session,
    options = list(
      "nextLabel" = "Next",
      "prevLabel" = "Previous",
      "skipLabel" = "Quit"
    ),
    events = list(
      "oncomplete" = I('alert("The tutoral is complete.  Enjoy the app!")')
    )
  )
)
# << start introjs
