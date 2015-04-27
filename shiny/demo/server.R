

# source('wordsScript.R')

#next two lines uncommented for 1405 destinations (more prettier version)
load("XML1405destRefiltered.RData")
keywordToDestinationWiki<-filteredWikivoyage
destinationToKeywordsWiki<-reFilteredWikivoyage

#next two lines uncommented for all destinations filtered by country, region and city but no heuristics
#load("xmlNoHeuristics.RData")
#wiki<-m


#next two lines uncommented for all unfiltered XML destinations (testing version)
#load("XMLComplete.RData")
#wiki<-filteredDestinationsKeywords

shinyServer(function(input, output) {
  output$plot <- renderPlot({
	if(input$radio == 1)
		   wordcloud_category(keywordToDestinationWiki, input$word, input$max)
	else
		wordcloud_city(destinationToKeywordsWiki, input$word, input$max)
	
	   #search(input$word,input$max)
  })
})