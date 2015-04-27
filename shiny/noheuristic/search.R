# procura.R

if(!exists('m'))
	load('m.RData')
source('utils.R')

search <- function(keywords, max=100,scalesize=c(4,.5))
{
	keywords <- transform_text(keywords)
	w <- rowSums(as.matrix(m[,keywords]))

	library(wordcloud)
	wordcloud(names(w), w, max.words=max, colors=brewer.pal(8,"Dark2"),scale=scalesize)
}
