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
source('utils.R')

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
					docs[[title]] <- transform_text(t)
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
