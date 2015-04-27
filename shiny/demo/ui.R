library(shiny)

shinyUI(fluidPage(
  # Application title
  titlePanel("MoonIT search preview"),

  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
radioButtons("radio", label = h3("Select criteria"),
    choices = list("Keyword to destination" = 1, "Destination to keyword" = 2,"Keyword to Keyword"=3), 
    selected = 3),
      textInput("word", "Keyword:", "snorkeling"),
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