load("dtm.RData")
load("adjacent_terms.RData")

adjacent_terms<-llply(dtm$dimnames$Terms, function(i) findAssocs(dtm, i, 0.07), .progress = "text" )
len <- length(adjacent_terms)
for (l in 1:len) { f <- data.frame(adjacent_terms[[l]])
                s <- paste("", colnames(f), sep = "") 
                w <- paste( s , ".csv", sep = "")
                write.csv(adjacent_terms[[l]], file = w)}

