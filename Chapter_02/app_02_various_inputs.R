## This shiny app illustrates a sidebar layout
## with lots of different input-widgets
## It also illustrates some formatting into
## columns.

library(shiny)
library(stringr)
library(TurtleGraphics)

## helper-fubctions to show colors:
turtle_square <- function(side) {
  turtle_do({
    for (i in 1:4) {
      turtle_forward(side)
      turtle_right(90)
    }
  })
}
turtle_show_color <- function(color) {
  turtle_init()
  turtle_col(color)
  turtle_lwd(50)
  turtle_do({
    turtle_setpos(x = 20, y = 20)
    turtle_square(70)
  })
}

ui <- fluidPage(
  titlePanel("Various Inputs"),
  sidebarLayout(
    sidebarPanel(
      textInput(
        inputId = "name",
        label = "What's your name?",
        value = "Pooh Bear"
      ),
      checkboxInput(
        inputId = "caps",
        label = "Shout at me!",
        value = FALSE
      ),
      textAreaInput(
        inputId = "paragraph",
        label = "Write a brief paragraph, and I'll count the number of words:",
        value = "Four score and seven years ago"
      ),
      selectInput(
        inputId = "fav_color",
        label = "What's your favorite color?",
        choices = colors(),
        selected = "bisque"
      ),
      sliderInput(
        inputId = "number",
        label = "Choose a number from 1 to 5000, and I'll double it:",
        value = 10,
        step = 1,
        min = 0,
        max = 5000
      )
    ),
    mainPanel(
      fluidRow(
        column(
          width = 6,
          verbatimTextOutput("greeting")
        ),
        column(
          width = 6,
          verbatimTextOutput("count")
        )
      ),
      fluidRow(
        plotOutput("swatch"),
        verbatimTextOutput("double")
      )
    )
  )
)

server <- function(input, output, session) {
  output$greeting <- renderText({
    msg <- str_c("Hello, ", input$name)
    if (input$caps) {
      msg <- str_to_upper(msg)
    }
    msg
  })

  output$count <- renderText({
    word_count <-
      input$paragraph %>%
      str_count(pattern = "\\b\\w+\\b")
    str_c("There are ", word_count, " words in your essay.")
  })

  output$swatch <- renderPlot({
    turtle_show_color(color = input$fav_color)
  })

  output$double <- renderText({
    str_c("Twice ", input$number, " is ", 2 * input$number, ".")
  })
}

shinyApp(ui, server)
