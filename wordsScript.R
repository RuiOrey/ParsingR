load_libraries<-function(){
  require("bigmemory")
  require ("XML")
  require ("RCurl")
  require ("tm")
  require("SnowballC")
  require("wordcloud")
  require("data.table")
  
}


# XML and RCurl need specific XML an Curl operating system libs installed
install_libraries<-function(){
  install.packages(c("XML","RCurl","tm","SnowballC","wordcloud","XLConnect","data.table"))
}



find_words <-function (number=1) {
  require ("XML")
  require ("RCurl")
  require ("tm")
  require("SnowballC")
  require("wordcloud")
  require("XLConnect")
  
  #capitals <- read.csv('capitals.csv', colClasses='character')[,1]
  #capitals <- c("London","Jamaica","Porto","Lisbon","Cairo")
  capitals <- read.csv('Destinations.csv', colClasses='character',header = FALSE,sep = ",")
  #url <- 'http://en.wikipedia.org/wiki/'
  stop1<-read.csv("stopwords.csv",header = F,sep = "")
  if (number==1)
  url <- 'http://wikitravel.org/en/'
  else
  url <- 'https://en.wikivoyage.org/wiki/'
  docs <- NULL
  dat2 <- NULL
  capitals <- t(capitals)
  as.data.frame(sapply(capitals, function(x) gsub("\"", "", x)))
  urls <- paste(url, capitals, sep='')
  
  i <- 0
  # podia ser paralelizado (par.apply) para fazer download ao mesmo tempo
  if (TRUE){

    for(u in urls) {
      i<-i+1
      doc <- getURL(u)
      print(paste(u,i))
      # tidyHTML
      html <- htmlTreeParse(doc, useInternal=TRUE)
      txt <- xpathApply(html, "//body//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)]", xmlValue)
      txt <- paste(unlist(txt), collapse=' ')
      txt <- gsub('\\t', '', txt)
      txt <- gsub('\\n', '', txt)
      txt <- stripWhitespace(txt)
      txt <- tolower(txt)
      txt <- removeWords(txt, stopwords('english'))
      txt <- removeWords(txt, as.character(stop1[[1]]))
      txt <- removeNumbers(txt)
      txt <- removePunctuation(txt)
      #dat2 <- unlist(strsplit(txt,split=", "))
      #print("dat2")
      #print(dat2)
      #dat3 <- iconv(dat2, "latin1", "ASCII", sub="dat2")
      #print("dat3")
      #print(dat3)
      #dat4<-dat2[-dat3]
      #print("dat4")
      #print(dat4)
      #dat5<-paste(dat4,collapse=", ")
      #print("dat5")
      #print(dat5)
      #corpus <- Corpus(VectorSource(dat2))
      #dat4 <- tm_map(corpus, removeWords, c(stopwords("english"),as.character(stop1[[1]]),dat3))
     # txt <- paste(dat4, collapse = " ")
     # print(txt)
      # txt <- stemDocument(txt, 'english')
      docs <- c(docs, unlist(txt))
      #print(docs)
    }
  }
  print(as.character(stop1[[1]]))
  chinaRemove <- grep("docs", iconv(docs, "latin1", "ASCII", sub="docs"))
  
  
  corpus <- Corpus(VectorSource(docs))
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, removeWords, as.character(stop1[[1]]))
  corpus <- tm_map(corpus, removeWords, chinaRemove)
  
    #corpus[[1]] <- stemDocument(corpus[[1]])
      #print(corpus)
      dtm <- DocumentTermMatrix(corpus)
      tfidf <- weightTfIdf(dtm,normalize = TRUE)
      m <- as.matrix(tfidf)
    #print(m)
    
    rownames(m) <- capitals
    m
  }
  
  bake_results<-function(m){
    require("bigmemory")
    #m4 <- apply(m, 1, function(x) names(sort(x, TRUE)))
    keywords_destino <- apply(m, 1, function(x) names(sort(x, TRUE)[1:1000]))
    keywords_destino_T <- t(keywords_destino)  # para ocupar menos espaço
    #colnames(m3) <- as.character(1:number)
    #kable(m3)
    #m1
    keywords_destino_T_Freque <- sort(table(keywords_destino_T) , decreasing = TRUE)
    #m3
    print(head(keywords_destino_T_Freque, n = 100L))
    keywords_destino_T_Freque_DM<-data.matrix(keywords_destino_T_Freque,rownames.force = TRUE)
    
    for (i in 1:3) {
      print (rownames(m)[i])
      print (rownames(keywords_destino_T_Freque)[i])
      print (m[i,rownames(keywords_destino_T_Freque)[i]])
    } 
    #wordcloud(names(head(keywords_destino_T_Freque[],n=200)),head(keywords_destino_T_Freque[],n=200),scale=c(0.05,1.5),min.freq = 150,max.words = 150,colors=brewer.pal(8,"Dark2"),random.order = T)
    wordcloud(names(head(keywords_destino_T_Freque[],n=100)),head(keywords_destino_T_Freque[],n=100),scale=c(8,.2),min.freq = 7,max.words = Inf,colors=brewer.pal(8,"Dark2"),random.order = F)
    keywords_destino_T_Freque
  }

  filterSiteByKeywords<-function(wikiSite,wikiKeywords,minimum_ocurrences=100){
    new_wiki<-wikiSite[,names(wikiKeywords[wikiKeywords>minimum_ocurrences])]
    new_wiki
  }
  
#plot
graphic_words_locations<-function(wikicorpus,keyword_array,word){
  plot(sort(wikicorpus[,names(keyword_array[word])]),main=names(keyword_array[word]),ylab = "Peso",xlab = "Destino")
  text(sort(wikicorpus[,names(keyword_array[word])]), labels = names(sort(wikicorpus[,names(keyword_array[word])])), cex=1)
}

keywords_cloud<-function(keywords_vector,optional_filename=NULL,numb=200,freq_min=2,title="Title"){
  if (!is.null(optional_filename) ){
    png(optional_filename, width=1280,height=1280)
  }
  wordcloud(names(head(keywords_vector,n=numb)),head(keywords_vector,n=numb),scale=c(2,0.1),min.freq = freq_min,max.words = 200,colors=brewer.pal(8,"Dark2"),random.order = T,main="title")
  if (!is.null(optional_filename)){
    dev.off()
  }
}

wordcloud_category_both<-function(category,wiki1,wiki2,max=30){
  old.par<-par(mfrow=c(1,2))
  wordcloud_category(filteredWikivoyage,category,max)
  wordcloud_category(filteredWikitravel,category,max)
  par(old.par)
}


#colnames(t(sort(m[,"night)"],decreasing = T)))

wordcloud_city<-function(wiki,city,max=100){
  require("wordcloud")
  wordcloud(names(wiki[city,]),wiki[city,],scale=c(4,.5),min.freq = 5,max.words = max,colors=brewer.pal(8,"Dark2"),random.order = F,main="title")
}

wordcloud_category<-function(wiki,word,max=100){
  require("wordcloud")
  #print(max)
  wordcloud(names(wiki[,word]),wiki[,word],
  colors=brewer.pal(8,"Dark2"),
  #scale=c(4,.5),
  #min.freq = 5,
  max.words = max)
}


searchXMLSite<-function(xml_data,index_site,index_sub){
  xml_data[[index_site]][index_sub]
  #xml_data[[26000]][[4]][[7]][1] <- text
  #xml_data[[51575]][[1]] <- title
  a<-c()
  for(i in 1:51573){
    a<-c(a,xml_data[[i]][[1]])
  }
}

getXmlRoot<-function(file="enwikivoyage-latest-pages-articles.xml"){
  xml<-xmlParse(file)
  xmlRoot(xml)
}

getTitleOfPage<-function(xml_root,index){
  xmlValue(xml_root[[index]][[1]])
}
# it seems cities have {{usablecity}} in their text
getTextOfPage<-function(xml_root,index){
  xmlValue(xml_root[[index]][[4]][[8]])
}

#the next 2 functions are to set parameters to filter text
textIsCity<-function(textOfPage){
  #grepl("usablecity",textOfPage)
  #!is.na(textOfPage) && (nchar(textOfPage)>100) && grepl("usablecity",textOfPage)
  !is.na(textOfPage) && (nchar(textOfPage)>100) 
}

nameIsCity<-function(titleOfPage){
  a<-! (grepl("Wikivoyage",titleOfPage))
  a<-! (grepl(":",titleOfPage))
  a
}


find_words_xml<-function(a){
  print("starting find_words_xml")
  docs<-a$text
  stop1<-read.csv("stopwords.csv",header = F,sep = "")
  
  chinaRemove <- grep("docs", iconv(docs, "latin1", "ASCII", sub="docs"))
  
  print("transforming text in corpora...")
  corpus <- Corpus(VectorSource(docs))
  print("Corpora obtained. Filtering text...")
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, removeWords, as.character(stop1[[1]]))
  corpus <- tm_map(corpus, removeWords, chinaRemove)

  corpus <- tm_map(corpus, content_transformer(tolower))
  #corpus <- tm_map(corpus, content_transformer(stri_trans_tolower))
  corpus <- tm_map(corpus, content_transformer(removePunctuation))
  corpus <- tm_map(corpus, content_transformer(removeNumbers))
  
  #corpus.copy<-corpus
  #corpus <- tm_map(corpus, content_transformer(stemDocument))
  #corpus <- tm_map(corpus, stemCompletion,dictionary=corpus.copy)
  
  corpus <- tm_map(corpus, PlainTextDocument)
  #corpus[[1]] <- stemDocument(corpus[[1]])
  #print(corpus)
  print("Filtered. Converting in dtm...")
  dtm <- DocumentTermMatrix(corpus,control=list(wordLengths=c(2,10)))
  #print(inspect(dtm))
  #testing
  print("Removing sparse terms...")
  dtm <- removeSparseTerms(x = dtm, sparse = 0.99)
  print(inspect(dtm))
  print("Dtm done. Tfidf...")

  tfidf <- weightTfIdf(dtm,normalize = TRUE)

   
  print("Finished find_words_xml. Returning tfidf.")
  tfidf
  
}

 tfidfToMatrix<-function(tfidf,a){
  print("Converting tfidf to matrix.")
  m <- as.matrix(tfidf)
  rownames(m) <- a$name
  print("Done tfidf-to-matrix.")
  print(str(m))

  m
 }


getCityTextTable<-function(xml_root){
  require("data.table")
  load_libraries()
  stop1<-read.csv("stopwords.csv",header = F,sep = "")
  
  cities=c()
  text=c()
  xsize<-xmlSize(xml_root)
  j<-0
  for (i in 1:xsize){
    txt<-getTextOfPage(xml_root,i)
    city<-getTitleOfPage(xml_root,i)
    if (textIsCity(txt) && nameIsCity(city)){
      txt <- gsub('\\t', '', txt)
      txt <- gsub('\\n', '', txt)
      txt <- stripWhitespace(txt)
      txt <- tolower(txt)
      txt <- removeWords(txt, stopwords('english'))
      txt <- removeWords(txt, as.character(stop1[[1]]))
      txt <- removeNumbers(txt)
      txt <- removePunctuation(txt)
      text<-c(text,txt)
      
      cities<-c(cities,city)
      
      j<-j+1
      print(j)
      print(city)
    }
  }
  DT=data.table(name=cities,text=text)
  DT
}

#main function to get the xml table (does all the work, read, filter, parse and save)
readXMLandGetDataTable<-function(){
  print("starting readXMLandGetDataTable")
  require("XML")
  a<- getXmlRoot()
  b<-getCityTextTable(a)
  print("finished readXMLandGetDataTable")
  b
} 

#uncomment the following line(s) to autorun the process at script reload
#loads libraries, runs the process and returns the filtered destination/keyword score table.
#a guide to know which functions to execute on the command line
#by the end of the process keywords has the words by order and filteredDestinationsKeywords has the destinations and keyword matching filtered

  load_libraries()
  xmlRawDataTable<-readXMLandGetDataTable()
  xmlCorpusScores<-find_words_xml(xmlRawDataTable)
  tfidfMatrix<-tfidfToMatrix(xmlCorpusScores,xmlRawDataTable)
  keywords<-bake_results(tfidfMatrix)
  filteredDestinationsKeywords<-filterSiteByKeywords(tfidfMatrix,keywords,100)


