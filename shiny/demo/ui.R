library(shiny)

shinyUI(fluidPage(
  # Application title
  titlePanel("Word Cloud demo"),

  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
radioButtons("radio", label = h3("Select criteria"),
    choices = list("Keyword to destination" = 1, "Destination to keyword" = 2), 
    selected = 1),
      textInput("word", "Keyword:", "surf"),
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