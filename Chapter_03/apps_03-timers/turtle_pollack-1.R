## This app shows illustrates the use of a timer reactive
## Problem:  it can throw an error when the user hasn't finished
## specifying the number of strokes.
## How can we fix this?

library(shiny)
library(TurtleGraphics)
library(stringr)

## define a turtle-painting function:
turtle_quick_pollack <- function(cols) {
  strokes <- length(cols)
  turtle_init(mode = "clip")
  turtle_lwd(50)
  turtle_do({
    for ( i in 1:strokes ) {
      current_color <- cols[i]
      turtle_col(current_color)
      random_angle <- runif(1, min = 0, max = 360)
      turtle_left(random_angle)
      turtle_forward(10)
    }
  })
}

## now for the shiny app:
ui <- fluidPage(
  titlePanel("Turtle Pollack"),
  sidebarLayout(
    sidebarPanel(
      numericInput(
        inputId = "strokes", 
        label = "Number of strokes for the next painting:",
        value = 30,
        step = 1,
        min = 1,
        max = 500
      )
    ),
    mainPanel(
      plotOutput("painting"),
      verbatimTextOutput("report")
    )
  )
)

server <- function(input, output, session) {
  
  timer <- reactiveTimer(intervalMs = 2000)
  
  colors_to_use <- eventReactive(timer(), {
    sample(colors(), size = isolate(input$strokes), replace = TRUE)
  })
  
  output$painting <- renderPlot({
    turtle_quick_pollack(cols = colors_to_use())
  })
  
  output$report <- renderText({
    msg <- "Behold my masterpiece!\nIt was created with the following colors:\n\n"
    color_list <- str_c(colors_to_use(), collapse = "\n")
    str_c(msg, color_list)
  })
}

shinyApp(ui, server)