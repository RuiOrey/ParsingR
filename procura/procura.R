# procura.R

if(!exists('m'))
	load('../pre/m.RData')

procura <- function(keywords, max=100)
{
	keywords <- strsplit(keywords, ' ')[[1]]
	w <- apply(as.matrix(m[,keywords]), 1, sum)

	library(wordcloud)
	wordcloud(names(w), w, max.words=max, colors=brewer.pal(8,"Dark2"))
}
