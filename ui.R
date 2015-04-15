library(shiny)

shinyUI(fluidPage(
  # Application title
  titlePanel("Word Cloud"),

  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      textInput("word", "Keyword:", "surf"),
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