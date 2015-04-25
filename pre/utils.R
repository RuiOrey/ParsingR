# utils.R

library(tm)

transform_text <- function(t)
{
	# utilizamos expressoes regulares inves de varias chamadas ao 'tm'
	# para ser mais rapido

	t <- gsub('\t\r\n\v\f[:digit:][:punct:]', '', tolower(t), useBytes=TRUE)
	t <- stripWhitespace(t)
	t <- removeWords(t, stopwords('english'))
	#t <- stemDocument(t, 'english')
	
	# transformar em vector, separados por espaços
	t <- strsplit(t, ' ', TRUE)[[1]]
	t <- sapply(t, function(x) stemDocument(x, 'english'))

	# remover tudo do vector o que não for letra ou apostrofo ou hifen
	t[!grepl('[^a-z\'\\-]', t)]
}
