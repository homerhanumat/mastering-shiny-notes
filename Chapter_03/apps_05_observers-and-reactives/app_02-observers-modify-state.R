## One good use for observers is
## to keep track of the "state" of an app.
## This is often done in conjunction with
## reactiveValues().


library(shiny)
library(glue)


## sidebar panel ----
sidebar <- sidebarPanel(
  numericInput(
    inputId = "n",
    label = "Countdown from:",
    min = 1,
    step = 1, value = 5
  ),
  actionButton("countdown", "Count Down!")
)

## main panel ----
main <- mainPanel(
  wellPanel(
    textOutput("report")
  )
)

## ui ----

## another way to get a sidebar layout:
ui <- pageWithSidebar(
  headerPanel = headerPanel(title = "Subtraction Game"),
  sidebarPanel = sidebar,
  mainPanel = main
)

## server logic ----

server <- function(input, output, session) {
  timer <- reactiveTimer(1000)

  rv <- reactiveValues(
    ## the "state" is where we are in the countdown:
    current = NULL
  )

  ## start countdown over again, if user changes n:
  observeEvent(input$countdown, {
    rv$current <- input$n
  })

  observeEvent(timer(), {
    req(rv$current)
    ## note that eventually rv$current will be negative:
    rv$current <- rv$current - 1
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
      ## rv$current is negative, so no more counting:
      ""
    }
  })
}

## start the app ----

shinyApp(ui, server)
