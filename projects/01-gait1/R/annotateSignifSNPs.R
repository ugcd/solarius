
annotateSignifSNPs <- function(A)
{
require(NCBI2R)

d <- dim(A$snpf)
posSig <- which(A$snpf$pSNP*d[1]<0.05)
snplist <- A$snpf$SNP[posSig]
b <- AnnotateSNPList(snplist)

b[1:12]
}
