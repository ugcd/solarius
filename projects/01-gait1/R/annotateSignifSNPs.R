
annotateSignifSNPs- function(A, file="resultsAnnotation.txt")
{
require(NCBI2R)

load("resultsF11.Rdata")

posSig <- which(A$snpf$pSNP*307984<0.05)
snplist <- A$snpf$SNP[posSig]
b <- AnnotateSNPList(snplist)

write.table(b[1:12], file=file)
}
