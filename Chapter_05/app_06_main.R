##
## Stage 6
##
## Add popup tutorial,
## Now that it's a long app, split into separate files.
##

library(tidyverse)
library(vroom)
library(shinydashboard)
library(shinyjs)
library(rintrojs)
library(tippy)
library(glue)

## globals ----

source("globals.R")

## ui ----

source("app_06_ui.R")

## server ----

server <- function(input, output, session) {
  source("app_06_reactive_logic.R", local = TRUE)
}

## make app ----

shinyApp(ui, server)
