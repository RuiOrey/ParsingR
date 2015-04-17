load('space.Rdata')
library(lsa)
m <- as.textmatrix(space)


lista_termos <- function()
{
	rownames(m)
}


parecidos_com <- function(termo, max=20)
{
	w <- sort(associate(m, termo), TRUE)

	library(wordcloud)
	wordcloud(names(w), w, max=max)
}


procura <- function(keywords, max=20)
{
	q <- query(keywords, rownames(m), stemming=TRUE, language='english')
	q <- fold_in(q, space)

	qd <- 0
	for (i in 1:ncol(m))
		qd[i] <- cosine(as.vector(q), as.vector(m[,i]))

	w <- qd
	o <- order(w,decreasing=TRUE)
	w <- w[o]
	n <- colnames(m)[o]

	library(wordcloud)
	wordcloud(n, w, max=input$max)
}
