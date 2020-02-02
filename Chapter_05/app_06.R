##
## Stage 6
##
## Add popup tutorial!
##

library(tidyverse)
library(vroom)
library(shinydashboard)
library(shinyjs)
library(rintrojs)
library(tippy)
library(glue)

## globals ----

table_bg_color <- "light-blue"
dashboard_skin <- "yellow"

## for the tutorial
app_intro <- HTML(glue::glue("
This app explores data from the 
<a href='https://www.cpsc.gov/Research--Statistics/NEISS-Injury-Data' 
target='_blank'>National 
Electronic Injury Surveillance System</a> (NEISS). 
NEISS records all accidents seen 
in a representative sample of hospitals in the United States.
(The data we have here is a subset of the overall data, so the
app won't take too long to load.)
"))

## for the graph y-axis tooltip
units_info <- HTML(glue::glue(
  "The default choice is for the y-axis of the graph to show an estimate of the 
  <em>rate per 10,000</em>,
  i.e.:  the number of accidents out of every ten thousand people of the 
  given age in the population.  The choice 'rate' switches to an estimate of the
  total number itself.  (The 'rate' choice can be misleading, as the sizes 
  of the age-groups vary.)"
))

if (!exists("injuries")) {
  injuries <- vroom::vroom("neiss/injuries.tsv.gz")
  products <- vroom::vroom("neiss/products.tsv")
  population <- vroom::vroom("neiss/population.tsv")
}

count_top <- function(df, var, n = 5) {
  df %>%
    mutate({{ var }} := fct_lump(fct_infreq({{ var }}), n = n)) %>%
    group_by({{ var }}) %>%
    summarise(n = as.integer(sum(weight)))
}

## ui ----

ui <- dashboardPage(
  skin = dashboard_skin,
  dashboardHeader(title = "Injuries"),
  dashboardSidebar(
    useShinyjs(),
    introjsUI(),
    use_tippy(),
    sidebarMenu(
      id = "tabs",
      div(
        style = "margin-left: 20px; margin-top: 20px;",
        tagList(
          introBox(
            menuItem(text = "Tables/Stories", tabName = "tables", icon = icon("table")),
            data.step = 7,
            data.intro = glue::glue(
              "The app starts on the tab that shows the tables and the random narrative.
              You can always return to the tables tab by clicking on this menu item.
              \n\nThis is the last item in our tutorial.  Click Done to finish."
            )
          ),
          div(style = "height: 20px;"),
          introBox(
            menuItem(text = "Graph", tabName = "graph", icon = icon("chart-area")),
            data.step = 6,
            data.intro = glue::glue(
              "Click on this menu itme to be taken to a graph
              of the number of accidents associated with the
              selected product.  Look for tool-tips that will tell you
              more about how to control the graph."
            )
          ) # end introbox
        ) # end taglist
      ), # end enclosing div,
      br(),
      introBox(
        selectInput("code", "Product",
          choices = setNames(products$prod_code, products$title),
          width = "100%"
        ),
        data.step = 2,
        data.intro = glue::glue(
          "'Product' refers to the type of item that was involved in 
        the person's accident.  Scroll down the list of choices and select
        your favorite one!"
        )
      ),
      introBox(
        actionButton("help", HTML("Press for a tutorial!")),
        data.step = 1,
        data.intro = app_intro,
        data.position = "right"
      )
    )
  ),
  dashboardBody(
    tags$style(
      HTML(
        glue::glue("
                    .tippy-tooltip {
                      font-size: 1.5rem !important;
                      padding: 0.3rem 0.6rem;
                      }
                   ", .open = "{{")
      )
    ),
    tabItems(
      tabItem(
        tabName = "tables",
        fluidRow(
          introBox(
            box(
              width = 4,
              title = "Diagnosis",
              status = "primary",
              solidHeader = TRUE,
              background = table_bg_color,
              tableOutput("diag")
            ),
            data.step = 2,
            data.intro = glue::glue(
              "Here we tally up the accidents by the medical diagnosis given to the
              injury.  The 'n' column is an estimate of how
              many accidents of the selected type result in the given diagnosis,
              each year."
            )
          ),
          introBox(
            box(
              width = 4,
              title = "Body Part",
              status = "primary",
              solidHeader = TRUE,
              background = table_bg_color,
              tableOutput("body_part")
            ),
            data.step = 3,
            data.intro = glue::glue(
              "Here we tally up the accidents by what part of the
              body was injured.  The 'n' column is an estimate of how
              many people in the U.S. sustain this type of injury each year."
            )
          ),
          introBox(
            box(
              width = 4,
              title = "Location of Injury",
              status = "primary",
              solidHeader = TRUE,
              background = table_bg_color,
              tableOutput("location")
            ),
            data.step = 4,
            data.intro = glue::glue(
              "Here we tally up the accidents by the sort of place
              where the accident occurred.  The 'n' column is an estimate of how
              many accidents of the selected type occur in the given location
              each year."
            )
          )
        ), # <<row
        br(),
        fluidRow(
          column(
            2,
            introBox(
              actionButton("story", "Tell me a story"),
              data.step = 5,
              data.intro = glue::glue(
                "This is the (morbidly) fun part!  Every time you clikc this button
                     the app will pick a random accident associated with the
                     product you have selected, and will display the narrative
                     of how the accident occurred."
              )
            )
          ),
          column(10, textOutput("narrative"))
        ) # <<row
      ), # <<tabItem,
      tabItem(
        tabName = "graph",
        fluidRow(
          box(
            width = 12,
            title = "Occurrences by Age and Gender",
            status = "primary",
            solidHeader = TRUE,
            plotOutput("age_sex")
          ),
          br(),
          div(
            style = "margin-left: 20px;",
            tagList(
              selectInput("y",
                tippy("Chhose Y-Axis Units (hover here for info)",
                  tooltip = units_info, width = "100px"
                ),
                choices = c("rate", "count")
              ),
              tippy_this("y", "Tooltip", placement = "right")
            ) # end taglist
          ) # end div
        ) # <<row
      ) # <<tabItem
    ) # <<tabItems
  ) # <<body
) # <<page

## server ----

server <- function(input, output, session) {
  observeEvent(input$tabs, {
    if (input$tabs == "tables") {
      show("help")
    } else {
      hide("help")
    }
  })

  selected <- reactive(injuries %>% filter(prod_code == input$code))

  # << tables
  output$diag <- renderTable(count_top(selected(), diag), width = "100%")
  output$body_part <- renderTable(count_top(selected(), body_part), width = "100%")
  output$location <- renderTable(count_top(selected(), location), width = "100%")
  # >>

  summary <- reactive({
    selected() %>%
      count(age, sex, wt = weight) %>%
      left_join(population, by = c("age", "sex")) %>%
      mutate(rate = n / population * 1e4)
  })

  # << plot
  output$age_sex <- renderPlot({
    if (input$y == "count") {
      summary() %>%
        ggplot(aes(age, n, colour = sex)) +
        geom_line() +
        labs(y = "Estimated number of injuries") +
        theme_grey(15)
    } else {
      summary() %>%
        ggplot(aes(age, rate, colour = sex)) +
        geom_line(na.rm = TRUE) +
        labs(y = "Injuries per 10,000 people") +
        theme_grey(15)
    }
  })
  # >>

  # << narrative
  output$narrative <- renderText({
    input$story
    selected() %>%
      pull(narrative) %>%
      sample(1)
  })
  # <<

  # start introjs when button is pressed with custom options and events
  observeEvent(
    input$help,
    introjs(session,
      options = list(
        "nextLabel" = "Next",
        "prevLabel" = "Previous",
        "skipLabel" = "Quit"
      ),
      events = list(
        "oncomplete" = I('alert("The tutoral is complete.  Enjoy the app!")')
      )
    )
  )
}

## make app ----

shinyApp(ui, server)
