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

categoryTest<-function(t){
	quality<-c("outline","usable","guide","star")
	type<-c("city","country","region")
	typequality0<-unlist(lapply(quality,paste,type,sep=","))
	typequality<-unlist(lapply(quality,paste,type,sep=""))

	# da erro com {{ }}, entao a usar so }}
	#typequality<-do.call(paste, c(as.list(typequality), sep="|")) 
	typequalityf<-paste(unlist(typequality),"}}",sep="")
	
	la<-lapply(unlist(typequalityf),grepl,t)
	la<-unlist(la)
	if (length(which(la))==1){
		typequality0[which(la)]
	}
	else{
		"false"
	}

}

getFather <- function(t,breakrule=F){
	if(grepl("IsPartOf",t))
	{	
		partof<-gsub('.*IsPartOf\\|(.*?)\\}.*', '\\1', t)
		print(paste("PartOf:",partof))
		partof
}
else{
	"false"}
}

isRedirect <- function(t,breakrule=F){
	if(grepl("REDIRECT",t))
	{	redirect<-gsub('.*\\[\\[(.*?)\\]\\].*', '\\1', t)
	print(paste("REDIRECT:",redirect))
	redirect
}
else{
	"false"}
}

isValidDestination <- function(t,breakrule=F){

	#gera string com categorias para serem aceites como validas

	validDest<-categoryTest(t)
	if (validDest != "false"){
		print(validDest)
	}
	else{
		print("invalid category")
	}
	validDest
	

}

branches <- function() {
	docs <- new.env()  # inserir em env é ainda mais eficiente que list(), parece
	redirects <- new.env()
	father <- new.env()
	pagenumber<-0
	page <- function(node) {  # queremos ler as <page>
		n <- xmlChildren(node)
		pagenumber=pagenumber+1
		if(all(c('title','revision') %in% names(n))) {
			title <- xmlValue(n[['title']])
			if(!grepl(':', title)) {
				revision <- n[['revision']]
				n <- xmlChildren(revision)
								
				if('text' %in% names(n)) {

					print(pagenumber)
					print(title)
					# o parser repete chaves "text", dai temos que juntá-las
					t <- paste(sapply(n[names(n) == 'text'], xmlValue), collapse=' ')
					transformedText <-transform_text(t)
					#print(transformedText)
					validDestination<-isValidDestination(substitute(t))

					# FIXME: acho que o Rui verificava que o texto tinha um certo
					# tamanho. ie: length(t)>100
					if (validDestination!="false" && length(transformedText)>100){
						docs[[title]] <- transformedText
						father[[title]]<-getFather(t)
						}
						redirectDestination<-isRedirect(t)
						if (redirectDestination!= "false"){
							redirects[[redirectDestination]]<-c(redirects[[title]],title)

					}
				}
			}
		}
	}
	list(page=page, getDocs=function() as.list(docs),getRedirects=function() as.list(redirects),getFathers=function() as.list(father))
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
dtm <- removeSparseTerms(dtm, 0.995)
print("- Transformações da matriz ...")
#dtm <- weightTfIdf(dtm)
dtm <- weightSMART(dtm, 'ltc')
save(dtm, file='dtm.RData')

print("Gravar ...")
m <- as.matrix(dtm)
rownames(m) <- names(docs)
save(m, file='m.RData')
#write.csv(m, 'm.csv')
