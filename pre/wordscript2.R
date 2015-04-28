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
	if(grepl("[iI]s[pP]art[oO]f",t))
	{	
		partof<-gsub('.*[iI]s[pP]art[oO]f\\|(.*?)\\}.*', '\\1', t)
		print(paste("PartOf:",partof))
		partof
}
else{
	"false"}
}


getGeo <- function(t,breakrule=F){
	geo<-"false"
	if(grepl("\\{[gG]eo",t))
	{	
		geo<-gsub('.*\\{[gG]eo\\|(.*?)\\|(.*?)[\\}\\|].*', '\\1,\\2', t)
		print(paste("Geo:",geo))
		geo
}
else{
	print(paste("Geo:",geo))
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
	docs <- new.env()
	docs$text <- list()
	docs$redirects <- list()
	docs$father <- list()
	docs$type <- list()
	docs$quality <- list()
	docs$geo <- list()

	pagenumber <<- 0
	page <- function(node) {  # queremos ler as <page>
		n <- xmlChildren(node)
		pagenumber <<- pagenumber+1
		if(all(c('title','revision') %in% names(n))) {
			title <- xmlValue(n[['title']])
			if(!grepl(':', title)) {
				n <- xmlChildren(n[['revision']])
								
				if('text' %in% names(n)) {
					print(pagenumber)
					print(title)

					# o parser repete chaves "text", dai temos que juntá-las
					t <- paste(sapply(n[names(n) == 'text'], xmlValue), collapse=' ')
					tt <- transform_text(t)

					validDestination<-isValidDestination(substitute(t))

					if (validDestination!="false" && length(tt)>100) {
						docs$text[title] <- tt

						validDestination <- strsplit(validDestination,",")
						docs$quality[[title]] <- validDestination[0]
						docs$type[[title]] <- validDestination[1]
					}
					docs$father[[title]]<- getFather(t)
					docs$geo[[title]]<-getGeo(t)
					redirectDestination<-isRedirect(t)
					if (redirectDestination!= "false")
						docs$redirects[redirectDestination] <- c(docs$redirects[[redirectDestination]],title)
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
d <- b$getDocs()
corpus <- Corpus(VectorSource(d$text))
save(corpus, file='corpus.RData')

print("Para matriz documento-termo ...")
dtm <- DocumentTermMatrix(corpus, control=list(wordLengths=c(2,10)))
print("- Remover esparsos ...")
dtm <- removeSparseTerms(dtm, 0.992)
print("- Transformações da matriz ...")
#dtm <- weightTfIdf(dtm)
dtm <- weightSMART(dtm, 'ltc')
save(dtm, file='dtm.RData')

#print("Gravar ...")
#m <- as.matrix(dtm)
#rownames(m) <- names(docs)
#save(m, file='m.RData')
#write.csv(m, 'm.csv')

print("... obtendo dados de destinos...")
sorted_doc_sizes <- sort(as.data.frame(lapply(docs$text,length)), TRUE)

print("..gravando dados de destinos...")
save(sorted_doc_sizes,d$redirects,d$fathers,d$type,d$quality,d$geo,file="destinationData.RData")
print("Gravar matriz final...")
