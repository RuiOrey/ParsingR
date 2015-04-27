library(shiny)

shinyUI(fluidPage(
  # Application title
  titlePanel("One or more keyword search filtered by country, region and city."),

  sidebarLayout(
	
    # Sidebar with a slider and selection inputs
    sidebarPanel(
h6("No endpoint heuristics."),
      textInput("word", "Keyword:", "surf beach"),
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