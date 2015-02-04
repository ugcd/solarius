ManhattanPlot <- function(A)
{
require(qqman)
dataP <- as.data.frame(A$snpf)
dataP <- dataP[,c("SNP", "pSNP", "pos", "chr")]
names(dataP)[2] <- "P"
names(dataP)[3] <- "BP"
dataP$CHR <- as.numeric(dataP$chr)

pos <- which(is.na(dataP$CHR))
if(length(pos)) {
  dataPP<- dataP[-pos,]
} else {
  dataPP<- dataP
}

manhattan(dataPP)
}
