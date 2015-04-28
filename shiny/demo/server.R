

# source('wordsScript.R')

#next two lines uncommented for 1405 destinations (more prettier version)
load("XML1405dest.RData")

keywordToDestinationWiki<-filteredWikivoyage

load("XML1405destRefiltered.RData")
load("../noheuristic/dtm.RData")
destinationToKeywordsWiki<-reFilteredWikivoyage
require(wordcloud)

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
	if(input$radio == 3)
		   {	
			assoc<-tm::findAssocs(dtm,input$word,corlimit = 0.07)
			wordcloud(words = row.names(assoc),assoc, colors=brewer.pal(9,"BuGn"))
			}
	else
		wordcloud_city(destinationToKeywordsWiki, input$word, input$max)
	
	   #search(input$word,input$max)
  })
})