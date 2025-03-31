## One good use for observers over reactives is
## to keep track of the "state" of an app

library(shiny)
library(glue)


## sidebar panel ----
sidebar <- sidebarPanel(
    numericInput("n", "Countdown from:", min = 1, step = 1, value = 5),
    actionButton("countdown", "Count Down!")
)

## main panel ----
main <- mainPanel(
  wellPanel(
    textOutput("report")
  )
)

## ui ----

ui <- pageWithSidebar(
  headerPanel = headerPanel(title = "Subtraction Game"),
  sidebarPanel = sidebar,
  mainPanel = main
)

## server logic ----

server <- function(input, output, session) {
  
  timer <- reactiveTimer(1000)
  
  rv <- reactiveValues(
    ## the "state" is where we are in the countdown
    current = NULL
  )

  observeEvent(input$countdown, {
    rv$current <- input$n
  })
  
  observe({
    timer()
    isolate({
      req(rv$current)
      rv$current <- rv$current - 1
    })
  })

 output$report <- renderText({
   req(rv$current)
  if (rv$current > 0) {
    glue::glue(
      "{rv$current}, ..."
    )
  } else if (rv$current == 0) {
    "Zero.  Blastoff!"
  } else {
    ""
  }
})
  
}

## start the app ----

shinyApp(ui, server)
