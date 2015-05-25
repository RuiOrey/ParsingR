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
		"not_valid_category"
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

testCountry<-function(text){
	if(grepl("=[Cc]ities=",text) || grepl("=[oO]ther [dD]estinations=",text))
		return("cut")
	if(grepl("=[gG]o [nN]ext=",text))
		return("no_cut")
	"cut"
}

cutHeuristics <- function(type,text,breakrule=F){
	if(type=="region")
		return("cut")
	if (type=="city")
		return("no_cut")
	return(testCountry(text))
}

branches <- function() {
	docs <- new.env()  # inserir em env é ainda mais eficiente que list(), parece
	docs_cutdown<- new.env()
	redirects <- new.env()
	father <- new.env()
	type <- new.env()
	articlequality<-new.env()
	geo<-new.env()

	pagenumber <<- 0
	destinations_count<<-0
	destinationsh_count<<-0
	page <- function(node) {  # queremos ler as <page>
		n <- xmlChildren(node)
		pagenumber <<- pagenumber+1  # n percebo porque ele dá sempre 1
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
					leng<-length(transformedText)
					if (validDestination!="false" && leng>100)
					{
						docs[[title]] <- transformedText
						destinations_count<--destinations_count+1
						validDestination<- strsplit(validDestination,",")
						articlequality[[title]]<-validDestination[0]
						ty<-validDestination[1]
						type[[title]]<-ty
						print(ty[[1]][[2]])
						heuristicTest<-cutHeuristics(ty[[1]][[2]],t) 
						if(heuristicTest=="no_cut"){
							docs_cutdown[[title]]<-transformedText
							print("ADDED TO CUT")
							destinationsh_count<<-destinationsh_count+1
						}
						else{
							validDestination<-"heuristicTest"
						}

	#					e "Cities" and "Other destinations" and add city-level headings like "Go next"; if such an article grows large enough, divide it into city districts.
						
					}
					if (validDestination!="false" && leng<100)
						validDestination<-"small"

					father[[title]]<- getFather(t)
					geo[[title]]<-getGeo(t)
					redirectDestination<-isRedirect(t)
					if (redirectDestination!= "false")
					{
						redirects[[redirectDestination]]<-c(redirects[[redirectDestination]],title)
					}
				}
			}
		}
	}
	list(page=page, getDocs=function() as.list(docs),getDocsHeuristic=function() as.list(docs_cutdown),getRedirects=function() as.list(redirects),getFathers=function() as.list(father),getType=function() as.list(type),getQuality=function() as.list(articlequality),getGeo=function() as.list(geo))
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

print("Operações sobre a matriz documento-termo ...")
dtm <- DocumentTermMatrix(corpus, control=list(wordLengths=c(2,15)))

print("- Remover esparsos ...")
dtm <- removeSparseTerms(dtm, 0.992)

print("- Transformações e calculos ...")
#dtm <- weightTfIdf(dtm)
dtm <- weightSMART(dtm, 'ltc')
save(dtm, file='dtm.RData')

print("Gravar como matriz sem heuristicas...")
m <- as.matrix(dtm)
rownames(m) <- names(docs)

print("... obtendo dados auxiliares de destinos...")
redirects<-b$getRedirects()
fathers<-b$getFathers()
type<-b$getType()
quality<-b$getQuality()
geo<-b$getGeo()
doccs<-b$getDocs()
doc_sizes<-lapply(doccs,length)
sorted_doc_sizes<-sort(as.data.frame(doc_sizes),decreasing=T)

print("..gravando dados de destinos...")
save(sorted_doc_sizes,redirects,fathers,type,quality,geo,file="destinationData.RData")
print("Gravar matriz final...")
save(m, file='m.RData')


print ("Gerando lista de termos correlacionados..")
adjacent_terms<-llply(dtm$dimnames$Terms, function(i) findAssocs(dtm, i, 0.07), .progress = "text" )
save(adjacent_terms,"adjacent_terms.RData")


print("Exportando para csv..")
write.csv(m, 'm.csv')
write.csv(redirects, 'redirects.csv')
write.csv(fathers, 'fathers.csv')
write.csv(type, 'type.csv')
write.csv(quality, 'quality.csv')
write.csv(geo, 'geo.csv')
write.csv(adjacent_terms, 'adjacent_terms.csv')

rm(m,dtm,corpus)


print("A gerar a matriz de documento-termo com heuristicas...")
docs_heuristics=b$getDocsHeuristic()
corpus_heuristics <- Corpus(VectorSource(docs_heuristics))

save(corpus_heuristics, file='corpus_heuristics.RData')

print("Operações sobre a matriz documento-termo ...")
dtm_heuristics <- DocumentTermMatrix(corpus_heuristics, control=list(wordLengths=c(2,10)))
print("- Remover esparsos ...")
dtm_heuristics <- removeSparseTerms(dtm_heuristics, 0.99)
print("- Transformações e calculos ...")
dtm_heuristics <- weightSMART(dtm_heuristics, 'ltc')
save(dtm_heuristics, file='dtm_heuristics.RData')

print("Converter para matriz com heuristicas...")
m_heuristics <- as.matrix(dtm_heuristics)

rownames(m_heuristics) <- names(docs_heuristics)
print("Gravar matriz final heuristicas...")
save(m_heuristics, file='m_heuristics.RData')



#write.csv(m, 'm.csv')
