##
## Stage 6
##
## Now that it's a long app, split into separate files.
## We also added a popup tutorial (package rintrojs)
## Package tippy provides tooltips on hover, for 
##  selected widgets.
## Package shinyjs helps hide/show elements.
## Package plotly makes our graph interactive.
##

library(tidyverse)
library(vroom)
library(shinydashboard)
library(shinyjs)
library(rintrojs)
library(tippy)
library(glue)
library(plotly)

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
