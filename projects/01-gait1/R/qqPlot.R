ManhattanPlot <- function(A)
{
require(qqman)
dataP <- A$snpf[,c("SNP", "pSNP", "pos", "chr")]
names(dataP)[2] <- "P"
names(dataP)[3] <- "BP"
dataP$CHR <- as.numeric(dataP$chr)

pos <- which(is.na(dataP$CHR))

dataPP<- dataP[-pos,]
qq(dataPP)
}
