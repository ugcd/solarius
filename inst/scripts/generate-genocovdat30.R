library(solarius)
library(plyr)

# number of SNPs to be generated
N <- 500 

data(dat30)

set.seed(7) # seed 7 results in one SNP associated with trait1

genocovdat30 <- t(laply(1:N, function(i) runif(nrow(dat30), 0, 2)))

colnames(genocovdat30) <- paste0("snp_", 1:ncol(genocovdat30))
rownames(genocovdat30) <- dat30$id

#> A <- solarAssoc(trait1 ~ 1, dat30, snpcovdata = genocovdat30, cores = 10)
#> summary(A)
#
#Call: solarAssoc(formula = trait1 ~ 1, data = dat30, snpcovdata = genocovdat30, 
#    cores = 10)
#
#Association model
# * Number of SNPs: 500 
# * Input format: snpcovdata 
# * Number of significal SNPs: 1 
#      SNP NAv      chi    pSNP     bSNP   bSNPse   Varexp  est_maf  est_mac
#1: snp_86 174 15.30657 9.1e-05 0.917024 0.234391 0.049701 0.524075 182.3781
#   dosage_sd
#1:  0.582544


