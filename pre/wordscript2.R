# wordscript2.R

# Cria e grava matrix "m", matriz filtrada das pontutações dos
# destinos/keywords.

if(!file.exists('xml')) {
	download.file('http://dumps.wikimedia.org/enwikivoyage/latest/enwikivoyage-latest-pages-articles.xml.bz2', 'xml.bz2')
	system('bunzip2 xml.bz2')
}

####################

library(XML)
library(tm)

branches <- function() {
	docs <- new.env()  # inserir em env é ainda mais eficiente que list(), parece

	page <- function(node) {  # queremos ler as <page>
		n <- xmlChildren(node)
		if(all(c('title','revision') %in% names(n))) {
			title <- xmlValue(n[['title']])
			if(!grepl(':', title)) {
				revision <- n[['revision']]
				n <- xmlChildren(revision)
				if('text' %in% names(n)) {
					print(title)
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
					t <- stemDocument(t, 'english')
					t <- iconv(strsplit(t, ' ', TRUE)[[1]], 'latin1', 'ASCII')

					docs[[title]] <- t
				}
			}
		}
	}
	list(page=page, getDocs=function() as.list(docs))
}


# usa modelo hibrido sax/dom do pacote: para todos os 'page'
# ele explora os seus conteúdos

b <- branches()
xmlEventParse('xml', branches=b, useTagName=FALSE, addContext=FALSE, ignoreBlanks=TRUE)

####################

print("A gerar a matriz de documento-termo ...")
docs <- b$getDocs()
corpus <- Corpus(VectorSource(docs))
save(corpus, file='corpus.RData')

print("Para matriz documento-termo ...")
dtm <- DocumentTermMatrix(corpus, control=list(wordLengths=c(2,10)))
print("- Remover esparsos ...")
dtm <- removeSparseTerms(dtm, 0.99)
print("- Transformações da matriz ...")
#dtm <- weightTfIdf(dtm)
dtm <- weightSMART(dtm, 'ltc')
save(dtm, file='dtm.RData')

print("Gravar ...")
m <- as.matrix(dtm)
rownames(m) <- names(docs)
save(m, file='m.RData')
#write.csv(m, 'm.csv')
