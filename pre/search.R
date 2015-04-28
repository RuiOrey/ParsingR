# procura.R

if(!exists('m'))
	load('m.RData')
if(!exists('sorted_doc_sizes'))
	load('sortedDocSizes.RData')
source('utils.R')

search <- function(keywords, max=100,scalesize=c(4,.5))
{
	keywords <- transform_text(keywords)
	w <- rowSums(as.matrix(m[,keywords]))

	library(wordcloud)
	wordcloud(names(w), w, max.words=max, colors=brewer.pal(8,"Dark2"),scale=scalesize)
}


search_documentSize <- function(keywords, max=100,scalesize=c(4,.5))
{
	keywords <- transform_text(keywords)
	w <- rowSums(as.matrix(m[,keywords]))
	w<-sort(w,decreasing=T)[1:max]
	namesW<-names(w)
	sorted_doc_filtered<-c()
	for (one in namesW){
	if (one %in% colnames(sorted_doc_sizes))
		sorted_doc_filtered[[one]]<-sorted_doc_sizes[[one]] 
	}
	w<-sort(sorted_doc_filtered,decreasing=T)
	w/w[1]
	require("wordcloud")
	wordcloud(names(w), w, max.words=max, colors=brewer.pal(8,"Dark2"),scale=scalesize)


}
