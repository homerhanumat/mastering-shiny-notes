## (1)  Reactives do "return" values

## (2)  When their dependencies change, a reactive
## does not run right away.  It waits until something
## that depends on it needs to run.

library(shiny)
library(ggplot2)

ui <- pageWithSidebar(
  headerPanel("With Reactives"),
  sidebarPanel(
    helpText(
      "Press both buttons quickly in succession,",
      " starting with the button for the task in the INACTIVE panel.",
      " You'll experience only about a 5-second wait to see new",
      " results in the active panel. (But then switch panels, and",
      " experience another 5-second wait!)"
    ),
    actionButton("a", "Task A (5 sec)"),
    actionButton("b", "Task B (5 sec)")
  ),
  mainPanel(
    tabsetPanel(
      tabPanel(
        title = "A Results", 
        wellPanel(plotOutput("a_results"))
      ),
      tabPanel(
        title = "B Results", 
        wellPanel(plotOutput("b_results"))
      )
    )
  )
)

server <- function(input, output, session) {
  a <- eventReactive(input$a, {
    Sys.sleep(5)
    data.frame(results = rnorm(1000))
  })
  b <- eventReactive(input$b, {
    Sys.sleep(5)
    data.frame(results = rnorm(1000))
  })
  output$a_results <- renderPlot({
    ggplot(a(), aes(x = results)) +
      geom_histogram(fill = "skyblue", color = "black") +
      labs(title = paste0("This took 5 seconds to produce."))
  })
  output$b_results <- renderPlot({
    ggplot(b(), aes(x = results)) +
      geom_histogram(fill = "burlywood", color = "black") +
      labs(title = paste0("This took 5 seconds to produce."))
  })
}

shinyApp(ui, server)
