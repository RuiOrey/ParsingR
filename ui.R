# app.R

library(shiny)




ui <- fluidPage(
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









server <- function(input, output) {
  output$plot <- renderPlot({
	  wordcloud_category(filteredWikivoyage, input$word, input$max)
  })
}








source('wordsScript.R')
load('Image.RData')
runApp(shinyApp(ui, server))
