library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Central limit theorem"),
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        inputId = "distribution",
        label = "Underlying Distribution",
        choices = c(
          "Normal" = "norm",
          "Uniform" = "unif",
          "Exponential" = "exp"
        ),
        selected = "norm",
      ),
      numericInput(
        inputId = "m", 
        label = "Sample Size:", 
        value = 1, 
        min = 1, 
        max = 100
      ),
      sliderInput(
        inputId = "bins", 
        label = "Number of bins", 
        value = 20,
        min = 5,
        max = 50,
        step = 5
      )
    ),
    mainPanel(
      plotOutput("hist")
    )
  )
)

server <- function(input, output, session) {
  
  output$hist <- renderPlot({
    if (input$distribution == "norm") {
      f <- function(n) {
        rnorm(n, mean = 0, sd = 1)
      }
    } else if (input$distribution == "unif") {
      f <- function(n) {
        runif(n, min= 0, max = 1)
      }
    } else {
      f <- function(n) {
        rexp(n, rate = 1)
      }
    }
    means <- numeric(10000)
    for (i in 1:10000) {
      random_sample <- f(input$m)
      means[i] <- mean(random_sample)
    }
    df <- data.frame(mean = means)
    df |> 
      ggplot(aes(x = mean)) +
      geom_histogram(
        bins = input$bins,
        color = "black",
        fill = "skyblue")
    })
  
}

shinyApp(ui, server)
