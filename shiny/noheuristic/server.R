

source('search.R')

#next two lines uncommented for 1405 destinations (more prettier version)
#load("XML1405dest.RData")
#wiki<-filteredWikivoyage

#next two lines uncommented for all destinations filtered by country, region and city but no heuristics
load("xmlNoHeuristics.RData")
load("sortedDocSizes.RData")
load("destinationData.RData")
#wiki<-m


#next two lines uncommented for all unfiltered XML destinations (testing version)
#load("XMLComplete.RData")
#wiki<-filteredDestinationsKeywords

shinyServer(function(input, output) {
  output$plot <- renderPlot({
	   #wordcloud_category(wiki, input$word, input$max)
	   search(keywords=input$word,max=input$max)
  })
output$plot2 <- renderPlot({
	   #wordcloud_category(wiki, input$word, input$max)
	   search_documentSize(keywords=input$word,max=input$max)
  })
output$ploth <- renderPlot({
	   #wordcloud_category(wiki, input$word, input$max)
	   search_heuristics(keywords=input$word,max=input$max)
  })
output$plothd <- renderPlot({
	   #wordcloud_category(wiki, input$word, input$max)
	   search_heuristics_documentSize(keywords=input$word,max=input$max)
  })
})