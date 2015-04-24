load('m.Rdata')
library(tm)


lista_termos <- function()
{
	colnames(m)
}


#parecidos_com <- function(termo, max=20)
#{
#	w <- sort(associate(m, termo), TRUE)
#
#	library(wordcloud)
#	wordcloud(names(w), w, max.words=max)
#}


procura <- function(keywords, max=20)
{
	keywords <- strsplit(keywords, ' ')[[1]]
	w <- apply(m[,keywords], 1, sum)

	library(wordcloud)
	wordcloud(names(w), w, max.words=max)
}
