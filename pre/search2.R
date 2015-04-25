# procura.R

if(!exists('m'))
	load('m.RData')
source('utils.R')

search <- function(keywords, max=1,scalesize=c(4,.5))
{
	keywords <- transform_text(keywords)
	keywords_destino <- apply(m, 1, function(x) names(sort(x, TRUE)[1:1000]))
	# keywords_destino_T_Freque_DM<-data.matrix(keywords_destino_T_Freque,rownames.force = TRUE)
	w <- rowSums(as.matrix(keywords_destino_T_Freque_DM[keywords,]))

	library(wordcloud)
	wordcloud(names(head(keywords_destino_T_Freque[],n=100)),head(keywords_destino_T_Freque[],n=100),scale=c(8,.2),min.freq = 7,max.words = Inf,colors=brewer.pal(8,"Dark2"),random.order = F)
}
