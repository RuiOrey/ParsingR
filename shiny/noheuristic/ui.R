library(shiny)

shinyUI(fluidPage(
  # Application title
  titlePanel("One or more keyword search filtered by country, region and city."),

  sidebarLayout(
	
    # Sidebar with a slider and selection inputs
    sidebarPanel(
h6("Some heuristics comparison."),
      textInput("word", "Keyword:", "surf beach"),
      hr(),
      sliderInput("max", "Maximum cities:", min=1,  max=500, value=100)
    ),

    # Show Word Cloud
    mainPanel(
	h2("by score"),
      plotOutput("plot"),	
	h2("by score and then by document size"),
      plotOutput("plot2"),
	
	h2("by score with cut heuristics, no regions"),
      plotOutput("ploth"),
	
	h2("by score with cut heuristics, no regions and then by document size"),
      plotOutput("plothd")
    )
  )
)
)