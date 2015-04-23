library(solarius)
library(plyr)

# number of SNPs to be generated
N <- 100 
M <- 500

data(dat30)

set.seed(7) # seed 7 results in one SNP associated with trait1

genocovdat30 <- t(laply(1:M, function(i) runif(nrow(dat30), 0, 2)))

colnames(genocovdat30) <- paste0("snp_", 1:ncol(genocovdat30))
rownames(genocovdat30) <- dat30$id

# subset
genocovdat30 <- genocovdat30[, 1:N]

### 
data(dat50)
mapdat30 <- rbind(
  data.frame(SNP = colnames(genocovdat30)[1:50],
    chr = snpdata$chrom, pos = snpdata$position, gene = snpdata$gene),
  data.frame(SNP = colnames(genocovdat30)[51:100],
    chr = snpdata$chrom, pos = 1e6 + snpdata$position, gene = paste0(snpdata$gene, 1))
)    

#> A <- solarAssoc(trait1 ~ 1, dat30, snpcovdata = genocovdat30, snpmap = mapdat30, cores = 2)
#> summary(A)
#
#Call: solarAssoc(formula = trait1 ~ 1, data = dat30, snpcovdata = genocovdat30, 
#    snpmap = mapdat30, cores = 2)
#
#Association model
# * Number of SNPs: 100 
# * Input format: snpcovdata 
# * Number of significal SNPs: 1 
#      SNP NAv      chi     pSNP     bSNP   bSNPse   Varexp  est_maf  est_mac
#1: snp_86 174 15.30657 0.000091 0.917024 0.234391 0.049701 0.524075 182.3781
#   dosage_sd      pos chr
#1:  0.582544 22883925   1



