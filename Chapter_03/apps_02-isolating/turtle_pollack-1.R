## this app is intended to let the user select the
## number of strokes, then make a painintg with
## the desired number of strokes along with a 
## report of the colors used.  But something is
## wrong.  Can you spot the error?

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

## example of use:
## turtle_quick_pollack(cols = sample(colors(), size = 30, replace = TRUE))

## now for the shiny app:
ui <- fluidPage(
  titlePanel("Turtle Pollack"),
  sidebarLayout(
    sidebarPanel(
      numericInput(
        inputId = "strokes", 
        label = "Number of Strokes",
        value = 30,
        step = 1,
        min = 1,
        max = 1000
      )
    ),
    mainPanel(
      plotOutput("painting"),
      verbatimTextOutput("report")
    )
  )
)

server <- function(input, output, session) {
  
  output$painting <- renderPlot({
    colors_to_use <- sample(colors(), size = input$strokes, replace = TRUE)
    turtle_quick_pollack(cols = colors_to_use)
  })
  
  output$report <- renderText({
    colors_to_use <- sample(colors(), size = input$strokes, replace = TRUE)
    msg <- "Behold my masterpiece!\nIt was created with the following colors:\n\n"
    color_list <- str_c(colors_to_use, collapse = "\n")
    str_c(msg, color_list)
  })
}

shinyApp(ui, server)