## This app uses an action button to control the response

library(shiny)
library(stringr)

ui <- fluidPage(
  textInput("name", "What's your name?"),
  actionButton(
    inputId = "greet",
    label = "Greet Me!"
  ),
  textOutput("greeting")
)

server <- function(input, output, session) {
  
  greeting <- eventReactive(input$greet, {
    str_c("Hello ", input$name, "!")
  })
  
  output$greeting <- renderText({
    greeting()
  })
}

shinyApp(ui, server)