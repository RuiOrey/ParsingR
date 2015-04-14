# app.R

library(shiny)




ui <- fluidPage(
  # Application title
  titlePanel("Word Cloud"),

  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      textInput("word", "Keyword:", ""),
      actionButton("update", "Change"),
      hr(),
      sliderInput("freq",
                  "Minimum Frequency:",
                  min = 1,  max = 50, value = 15),
      sliderInput("max",
                  "Maximum Number of Words:",
                  min = 1,  max = 300,  value = 100)
    ),

    # Show Word Cloud
    mainPanel(
      plotOutput("plot")
    )
  )
)









server <- function(input, output) {
  output$plot <- renderPlot({
	  wordcloud_category(filteredWikivoyage, input$word)
  })
}








source('wordsScript.R')
runApp(shinyApp(ui, server))
