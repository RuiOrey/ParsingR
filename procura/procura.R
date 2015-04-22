# procura.R

if(!exists('filteredWikivoyage'))
	load('../pre/XML1405dest.RData')

wordcloud_category <- function(keywords, max=100)
{
	keywords <- strsplit(keywords, ' ')[[1]]

	norm <- function(x) sqrt(sum(x^2))
	db <- filteredWikivoyage

	res <- apply(db[,keywords], 1, norm)

	# TODO: deveria aplicar mesmo tratamento a keywords q a texto
	# idealmente usariamos findAssocs do pacote 'tm'

	library('wordcloud')
	wordcloud(names(res), res,
		colors=brewer.pal(8,"Dark2"),
		max.words=max)
}
