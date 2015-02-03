library(qqman)

load("resultsF11.Rdata")


dataP <- A$snpf[,c("SNP", "pSNP", "pos", "chr")]
names(dataP)[2] <- "P"
names(dataP)[3] <- "BP"
dataP$CHR <- as.numeric(dataP$chr)



pos <- which(is.na(dataP$CHR))

dataPP<- dataP[-pos,]

png("plotF11.pdf")
manhattan(dataPP)
dev.off()

png("qqF11.pdf")
qq(dataPP$P)
dev.off()

