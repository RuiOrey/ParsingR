

# source('wordsScript.R')
wordcloud_city<-function(wiki,city,max=100){
  require("wordcloud")
  wordcloud(names(wiki[city,]),wiki[city,],scale=c(4,.5),min.freq = 5,max.words = max,colors=brewer.pal(8,"Dark2"),random.order = F,main="title")
}
#next two lines uncommented for 1405 destinations (more prettier version)
load("../noheuristic/m.RData")
load("../noheuristic/destinationData.RData")
wiki<-m

#next two lines uncommented for all destinations filtered by country, region and city but no heuristics
#load("xmlNoHeuristics.RData")
#wiki<-m


#next two lines uncommented for all unfiltered XML destinations (testing version)
#load("XMLComplete.RData")
#wiki<-filteredDestinationsKeywords

shinyServer(function(input, output) {
  output$plot <- renderPlot({

    wordcloud_city(wiki, input$destination)
    
    })
  output$choose_dataset <- renderUI({
    selectInput("destination", "Destinations", as.list(sort(row.names(wiki))),selected="Amsterdam")
    })

  output$summary <- renderPrint({
    #dataset <- datasetInput()
    type_destination<-type[input$destination][[1]][[1]][2]
    quality_wikivoyage_article<-type[input$destination][[1]][[1]][1]
    geo_destination<-geo[input$destination]
    father_destination<-fathers[input$destination]
    redirect_to_destination<-redirects[input$destination]
  #print(type_destination)
  print(quality_wikivoyage_article)
  print(geo_destination)
  print(father_destination)
  print(redirect_to_destination)

    #summary(dataset)
    })

  # Show the first "n" observations
  output$view <- renderTable({
    #head(datasetInput(), n = input$obs)
    })
  output$name <- renderText({ 
    input$destination
    })
  output$type <- renderText({ 
   type[input$destination][[1]][[1]][2]
   })
  output$quality <- renderText({ 
    paste("Article quality:", type[input$destination][[1]][[1]][1])
    })
  output$alias <- renderText({ 
    if (length(redirects[input$destination][[1]])>0)
    paste(redirects[input$destination][[1]]," || ")
    else
    "No aliases.."
    })

  output$father <- renderText({
   
    iteration<-T
    path<-input$destination
    actual_destination<-input$destination
    while(iteration){
      if (!is.null(fathers[actual_destination][[1]]) && fathers[actual_destination][[1]] != "false")
      {
        path<-paste(path, "<", fathers[actual_destination][[1]])
        actual_destination<-fathers[actual_destination][[1]]
      }
      else{
	actual_destination<-gsub("_", " ", actual_destination)
	     	if (!is.null(fathers[actual_destination][[1]]) != "false")
		      {
			path<-paste(path, "<", fathers[actual_destination][[1]])
			actual_destination<-fathers[actual_destination][[1]]
		      }
		else
      			iteration<-F
    		}
}
    path
    })
  output$cordinates<-renderText({
    geo[input$destination][[1]]
    })
  output$map <- renderPlot({
    require("ggmap")
    coords<-strsplit(geo[input$destination][[1]],split=",")
    ggmap(get_map(location = c(as.numeric(coords[[1]][2]),as.numeric(coords[[1]][1]))))
    })



  })