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
output$age_sex <- renderPlot({
  if (input$y == "count") {
    summary() %>%
      ggplot(aes(age, n, colour = sex)) +
      geom_line() +
      labs(y = "Estimated number of injuries") +
      theme_grey(15)
  } else {
    summary() %>%
      ggplot(aes(age, rate, colour = sex)) +
      geom_line(na.rm = TRUE) +
      labs(y = "Injuries per 10,000 people") +
      theme_grey(15)
  }
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