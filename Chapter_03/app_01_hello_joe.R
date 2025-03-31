library(shiny)
library(stringr)

ui <- fluidPage(
  textInput("name", "What's your name?"),
  textOutput("greeting")
)

server <- function(input, output, session) {
  output$greeting <- renderText({
    str_c("Hello ", input$name, "!")
  })
}

shinyApp(ui, server)