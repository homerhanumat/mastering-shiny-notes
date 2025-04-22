## Observers don't "return values", but they can still
## do useful work in your app, especially
## in combination with reactiveValues

## NOTE:  The following can be done with reactives
## (and reactives are actualy preferred for this
## type of problem)

library(shiny)
library(ggplot2)

## globals ----

histogram <- function(x1, x2, binwidth = 0.1, xlim = c(-3, 3)) {
  df <- data.frame(
    x = c(x1, x2),
    g = c(rep("x1", length(x1)), rep("x2", length(x2)))
  )
  
  ggplot(df, aes(x, fill = g)) +
    geom_histogram(binwidth = binwidth) +
    coord_cartesian(xlim = xlim)
}

## ui ----

ui <- fluidPage(
  fluidRow(
    column(3, 
           numericInput("lambda1", label = "lambda1", value = 3),
           numericInput("lambda2", label = "lambda2", value = 3),
           numericInput("n", label = "n", value = 1e4, min = 0),
           actionButton("simulate", "Simulate!")
    ),
    column(9, plotOutput("hist"))
  )
)
## server ----

server <- function(input, output, session) {
  
  rv <- reactiveValues(
    x1 = rpois(1e4, 3),
    x2 = rpois(1e4, 3)
  )
  
  observeEvent(input$simulate, {
    rv$x1 <- rpois(input$n, input$lambda1)
    rv$x2 <- rpois(input$n, input$lambda2)
  })
  
  output$hist <- renderPlot({
    histogram(rv$x1, rv$x2, binwidth = 1, xlim = c(0, 40))
  })
  
}

## run the app ----

shinyApp(ui, server)