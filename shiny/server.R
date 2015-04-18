source('wordsScript.R')
load("XML1405dest.RData")
shinyServer(function(input, output) {
  output$plot <- renderPlot({
	   wordcloud_category(filteredWikivoyage, input$word, input$max)
  })
})