## Cria ficheiro space.Rdata com matrix m, em que dá pontuação
## para várias cidades, usando wikivoyage.

get_terms_page <- function(page)
{
	library(RCurl)
	doc <- getURL(page)

	library(XML)
	html <- htmlTreeParse(doc, useInternal=TRUE)
	text <- xpathApply(html, "//body//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)]", xmlValue)

	# juntamos lista porque está partida pelos blocos html
	text <- paste(unlist(text), collapse=' ')
	text <- gsub('[\t\r\n\v\f]', '', tolower(text))
	
	# dividimos por palavras e retornamos vector
	# (e eliminamos não-inglesas)
	text <- unlist(strsplit(text, split=' '))
	iconv(text, 'latin1', 'ASCII')
}

get_terms <- function(url = 'https://en.wikivoyage.org/wiki/')
{
	capitals <- read.csv('destinations.csv',colClasses='character',header = FALSE,sep = ",")
	capitals <- t(capitals)
	urls <- paste(url, capitals, sep='')

	# paralelizado para fazer download ao mesmo tempo
	library(parallel)
	cl <- makeCluster(10)
	text <- parSapply(cl, urls, get_terms_page)
	stopCluster(cl)

	# para utilizar com pacote lsa, inves do tm
	# ele e' esquisito; precisa das coisas em ficheiros
	tempdir <- tempfile()
	dir.create(tempdir)
	for(i in 1:length(urls))
		write(text[[i]], file=paste(tempdir, gsub('_', ' ', capitals[i]), sep="/"))

	library(lsa)
	data(stopwords_en)
	textmatrix(tempdir,
			stemming=TRUE,
			stopwords=stopwords_en)
}

save_terms <- function(m)
{
	library(lsa)
	m <- get_terms()
	m <- lw_tf(m) * gw_idf(m)
	space <- lsa(m)
	save(space, file='space.Rdata')
}



#save_terms()
