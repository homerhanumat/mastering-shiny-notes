## This shiny app pulls from the mdsr public database
## the pool package manages connections ot the database
## when there are multiple users of the app
## see:  https://db.rstudio.com/
## especially the sections on DBI and pool

library(shiny)
library(shinythemes)
library(tidyverse)
library(pool)
library(glue)

pool <- dbPool(
  drv = RMySQL::MySQL(),
  dbname = "lahman",
  host = "mdsr.cdc7tgkkqd0n.us-east-1.rds.amazonaws.com", 
  user = "mdsr_public", 
  password = "ImhsmflMDSwR"
)
onStop(function() {
  poolClose(pool)
})

ui <- fluidPage(
  theme = shinytheme("darkly"),
  title = "DatabaseLahman",
  titlePanel("A Bit of (Database) Lahman"),
  sidebarLayout(
    sidebarPanel(
      selectInput("year", "Choose the Season", choices = 1910:2016,
                  selected = 2016),
      selectInput("stat", "Choose the Batting Statistic",
                  choices = c("HR", "SB", "CS", "RBI",
                              "R", "H", "2B", "3B"))
    ),
    mainPanel(
      tableOutput("leaders"),
      plotOutput("plot")
    )
  )
)

server <- function(input, output, session) {
  df <- reactive({
    query <- glue::glue(
      "SELECT concat(m.nameFirst, ' ', m.nameLast) AS Name, 
              b.lgID AS League, b.{input$stat}
      FROM Batting AS b
      JOIN Master AS m
      ON b.playerID = m.playerID
      WHERE yearID = {input$year}"
    )
    res <-
      pool %>% 
      dbGetQuery(query)
    data <- res %>% collect()
    #dbClearResult(res)
    data
  })
  output$leaders <- renderTable({
    isolate(stat <- as.symbol(input$stat))
    df() %>% 
      arrange(desc(!!stat)) %>% 
      select(Name, League, !!input$stat) %>% 
      head(5)
  })
  output$plot <- renderPlot({
    isolate(stat <- as.symbol(input$stat))
    df() %>% 
      ggplot(aes(x = League, y = !!stat)) +
      geom_violin(fill = "burlywood") +
      geom_jitter(width = 0.25, height = 0, size = 0.1) +
      labs(x = "League")
  })
}

shinyApp(ui, server)