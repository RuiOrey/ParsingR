

source('search.R')

#next two lines uncommented for 1405 destinations (more prettier version)
#load("XML1405dest.RData")
#wiki<-filteredWikivoyage

#next two lines uncommented for all destinations filtered by country, region and city but no heuristics
load("xmlNoHeuristics.RData")
#wiki<-m


#next two lines uncommented for all unfiltered XML destinations (testing version)
#load("XMLComplete.RData")
#wiki<-filteredDestinationsKeywords

shinyServer(function(input, output) {
  output$plot <- renderPlot({
	   #wordcloud_category(wiki, input$word, input$max)
	   search(keywords=input$word,max=input$max)
  })
})