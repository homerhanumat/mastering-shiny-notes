## The fix:  use isolate() to eliminate
## reactivity of the graph to input$lwd.

library(shiny)
library(TurtleGraphics)
library(stringr)

## define a turtle-painting function:
turtle_quick_pollack <- function(cols, angles, width, type) {
  strokes <- length(cols)
  turtle_init(mode = "clip")
  turtle_lwd(lwd = width)
  turtle_do({
    for ( i in 1:strokes ) {
      current_color <- cols[i]
      turtle_col(current_color)
      turning_angle <- angles[i]
      turtle_left(turning_angle)
      turtle_forward(10)
    }
  })
}

## example of use:
turtle_quick_pollack(
  cols = c("red","green", "blue"),
  angles = c(50, 100, 25),
  width = 40
)

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
      ),
      numericInput(
        inputId = "lwd", 
        label = "Width of Strokes:",
        value = 30,
        step = 1,
        min = 1,
        max = 80
      ),
      actionButton(
        inputId = "go",
        label = "Paint Now!"
      )
    ),
    mainPanel(
      plotOutput("painting"),
      tableOutput("report")
    )
  )
)

server <- function(input, output, session) {
  
  colors_to_use <- eventReactive(input$go, {
    sample(colors(), size = input$strokes, replace = TRUE)
  })
  
  angles <- eventReactive(input$go, {
    runif(input$strokes, min = 0, max = 460)
  })
  
  output$painting <- renderPlot({
    turtle_quick_pollack(
      cols = colors_to_use(),
      angles = angles(),
      width = isolate(input$lwd)
    )
  })
  
  output$report <- renderTable({
    data.frame(
      angle_turned = round(angles(), 1),
      color = colors_to_use()
    )
  })
}

shinyApp(ui, server)