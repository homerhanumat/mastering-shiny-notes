## This app greets the user by name, but responds too "quickly"

library(shiny)
library(stringr)

ui <- fluidPage(
  textInput(
    inputId = "name", 
    label = "What's your name?"
  ),
  textOutput("greeting")
)

server <- function(input, output, session) {
  output$greeting <- renderText({
    str_c("Hello ", input$name, "!")
  })
}

shinyApp(ui, server)