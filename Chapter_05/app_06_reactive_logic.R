## Initiate hint
hintjs(session, options = list("hintButtonLabel"="Hope this hint was helpful"),
       events = list("onhintclose"=I('alert("Wasn\'t that hint helpful")')))

## ensure toutorial button is present only on the 
## home tab
observeEvent(input$tabs, {
  if (input$tabs == "tables") {
    show("help")
  } else {
    hide("help")
  }
})

selected <- reactive(injuries %>% filter(prod_code == input$code))

# << tables
output$diag <- renderTable(count_top(selected(), diag), width = "100%")
output$body_part <- renderTable(count_top(selected(), body_part), width = "100%")
output$location <- renderTable(count_top(selected(), location), width = "100%")
# >>

summary <- reactive({
  selected() %>%
    count(age, sex, wt = weight) %>%
    left_join(population, by = c("age", "sex")) %>%
    mutate(rate = n / population * 1e4)
})

# << plot
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
      #geom_point(na.rm = TRUE) +
      labs(y = "Accidents per 10,000 people") +
      theme_grey(15)
  }
  ggplotly(p, tooltip = "text") %>% 
    plotly::config(displayModeBar = FALSE)
})
# >>

# << narrative
output$narrative <- renderText({
  input$story
  selected() %>%
    pull(narrative) %>%
    sample(1)
})
# <<

# start introjs when button is pressed
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