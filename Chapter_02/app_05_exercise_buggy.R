library(shiny)
library(ggplot2)

set.seed(4040)
variables <- list(
  normal = rnorm(100, mean = 70, sd = 3),
  right = rexp(100, rate = 1/70),
  left = 100 - rexp(100, rate = 1/30)
)

ui <- fluidPage(
  selectInput("dist", "Distribution", choices = names(variables)),
  verbatimTextOutput("summary"),
  tableOutput("plot")
)

server <- function(input, output, session) {
  variable <- reactive({
    variables[[input$dist]]
  })
  output$smmary <- renderPrint({
    results <- fivenum(variable())
    names(results) <- c("min", "Q1", "median", "Q3", "max")
    results
  })
  output$plot <- renderPlot({
    df <- data.frame(x = variable)
    ggplot(df, aes(x = x)) +
      geom_density(fill = "burlywood") +
      geom_rug()
  })
}

shinyApp(ui, server)

