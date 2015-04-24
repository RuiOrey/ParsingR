# wordscript2.R

# Cria e grava matrix "m", matriz filtrada das pontutações dos
# destinos/keywords.

if(!file.exists('xml')) {
	getURL('http://dumps.wikimedia.org/enwikivoyage/latest/enwikivoyage-latest-pages-articles.xml.bz2', 'xml.bz2')
	system('bunzip2 xml.bz2')
}

####################

library(XML)
library(tm)
txt <<- list()  # xmlEventParse escreve para aqui

# usa modelo hibrido sax/dom do pacote: para todos os 'page'
# ele explora os seus conteúdos
xmlEventParse('xml', branches=list(page=function(node) {
	n <- xmlChildren(node)
	if(all(c('title','revision') %in% names(n))) {
		title <- n[['title']]
		if(!grepl(':', xmlValue(title))) {
			revision <- n[['revision']]
			n <- xmlChildren(revision)
			if('text' %in% names(n)) {
				print(xmlValue(title))
				# o parser repete chaves "text", dai temos que juntá-las
				t <- paste(sapply(n[names(n) == 'text'], xmlValue), collapse=' ')

				# FIXME: acho que o Rui verificava que o texto tinha um certo
				# tamanho. ie: length(t)>100

				# transformações ao texto
				# podiamos tb fazer dps com tm_map(); não sei qual mais rapido
				# mas aqui conseguimos juntar várias coisas numa única expressão
				# regular

				# FIXME: ficava mais rápido usando formato 'perl=TRUE', ver:
				# http://www.phpreferencebook.com/tag/pcre/
				t <- gsub('\t\r\n\v\f[:digit:][:punct:]', '', tolower(t), useBytes=TRUE)
				t <- stripWhitespace(t)
				t <- removeWords(t, stopwords('english'))
				t <- iconv(strsplit(t, ' ', TRUE)[[1]], 'latin1', 'ASCII')

				txt[[xmlValue(title)]] <<- t
			}
		}
	}
}), useTagName=FALSE, addContext=FALSE, ignoreBlanks=TRUE)

####################

print("A gerar a matriz de documento-termo ...")
corpus <- Corpus(VectorSource(txt))
#save(corpus, file='corpus.RData')

print("Para matriz documento-termo ...")
dtm <- DocumentTermMatrix(corpus, control=list(wordLengths=c(2,10)))
print("- Remover esparsos ...")
dtm <- removeSparseTerms(dtm, 0.99)
print("- Transformações da matriz ...")
dtm <- weightSMART(dtm, 'ltc')
#save(dtm, file='dtm.RData')

print("Gravar ...")
m <- as.matrix(dtm)
rownames(m) <- names(txt)
save(m, file='m.RData')
#write.csv(m, 'm.csv')
