## This app "slowly, in response to an
## action button.
## It uses reactive values to keep track of state,
## and observers to modify the state.
## It also uses functions from the shinyjs package
## to easily show and hide elements.

library(shiny)
library(shinyjs)
library(TurtleGraphics)
library(stringr)

## define a turtle-painting function:
turtle_quick_pollack <- function(cols, angles) {
  strokes <- length(cols)
  turtle_init(mode = "clip")
  turtle_lwd(50)
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
# turtle_quick_pollack(
#   cols = c("red","green", "blue"),
#   angles = c(50, 100, 25)
# )
  
  
## now for the shiny app:
ui <- fluidPage(
  ## to use shinyjs functions you put this in the UI somewhere:
  useShinyjs(),
  ## now the UI that the user sees:
  titlePanel("Turtle Pollack"),
  sidebarLayout(
    sidebarPanel(
      numericInput(
        inputId = "strokes", 
        label = "Number of Strokes",
        value = 5,
        step = 1,
        min = 1,
        max = 1000
      ),
      actionButton(
        inputId = "go",
        label = "Paint!"
      )
    ),
    mainPanel(
      plotOutput("painting"),
      verbatimTextOutput("report")
    )
  )
)

server <- function(input, output, session) {
  
  ## the state of the app:
  rv <- reactiveValues(
    ## to know what to show the user, the app needs to know
    ## three things:
      ## (1) colors already used at each step:
    colors = character(),
      ## (2) angles already used at each step:
    angles = numeric(),
      ## (3) whether or not we are (still) painting:
    painting = FALSE
  )
  
  ## app will wait half a second before adding a new stroke:
  timer <- reactiveTimer(500)
  
  observeEvent(timer(), {
    req(!is.na(input$strokes))
    if (rv$painting & length(rv$colors) < input$strokes) {
      ## we need to add another stroke, so:
      rv$colors <- c(rv$colors, sample(colors(), size = 1))
      rv$angles <- c(rv$angles, runif(1, min = 0, max = 360))
    }
  })
  
  ## action button resets state to the beginning of a new
  ## painting:
  observeEvent(input$go, {
    req(!is.na(input$strokes))
    rv$colors <- character()
    rv$angles <- numeric()
    rv$painting <- TRUE
    ## shiny js functions to hide the controls while painting:
    hide("strokes")
    hide("go")
  })
  
  ## whenever a new stroke has been made,
  ## determine whether we are done painting:
  observeEvent(rv$colors, {
    len <- length(rv$colors)
    if (len >= input$strokes) {
      ## done paitning so:
      rv$painting <- FALSE
      ## also show controls so user can paint again:
      show("strokes")
      show("go")
    }
  })
  
  output$painting <- renderPlot({
    ## stops running, with helpful message, if the user has not
    ## entered the number of strokes:
    validate(
      need(
        !is.na(input$strokes),
        "I won't paint until I know the number of strokes!"
      )
    )
    ## are we working on a painting?
    ## (if so we need to show the work-in-progress):
    working <- rv$painting & length(rv$colors) > 0
    ## are we done painting?
    ## (if so we need to show the finished product):
    done <- length(rv$colors) == input$strokes
    if (working | done) {
      turtle_quick_pollack(cols = rv$colors, angles = rv$angles)
    }
  })
  
  output$report <- renderText({
    req(!is.na(input$strokes))
    ## if done with a painting, issue a report:
    if (length(rv$colors) == input$strokes) {
      msg1 <- "Behold my masterpiece!\n"
      msg2 <- "It was created with the following colors:\n\n"
      color_list <- str_c(rv$colors, collapse = "\n")
      str_c(msg1, msg2, color_list)
    }
  })
}

shinyApp(ui, server)