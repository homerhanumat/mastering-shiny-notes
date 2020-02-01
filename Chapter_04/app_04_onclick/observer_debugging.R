library(shiny)

ui <- fluidPage(
  textInput("name", "Your Name Here", value = ""),
  textOutput("greeting")
)

server <- function(input, output, session) {
  
  text <- reactive(paste0("Hello ", input$name, "!"))
  
  output$greeting <- renderText(text())
  
  observeEvent(input$name, {
    message("Greeting performed")
  })
  
}

shinyApp(ui, server)