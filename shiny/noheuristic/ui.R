library(shiny)

shinyUI(fluidPage(
  # Application title
  titlePanel("Word Cloud filtered by country, region and city.\n No endpoint destination heuristics."),

  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      textInput("word", "Keyword:", "surf beach"),
      actionButton("update", "Change"),
      hr(),
      sliderInput("max", "Maximum cities:", min=1,  max=500, value=100)
    ),

    # Show Word Cloud
    mainPanel(
      plotOutput("plot")
    )
  )
)
)