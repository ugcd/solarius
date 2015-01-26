library(solarius)

### par
# phenotype dir
pdir <- "/home/datasets/GAIT1/GWAS/SFBR"
pfile <- file.path(pdir, "gait1.phe")

gdir1 <- file.path(pdir, "Impute/c1.1.500/")
gdir2 <- file.path(pdir, "Impute/c1.501.1000/")

### read phen. data
pdat <- read.table(pfile, header = TRUE,
  stringsAsFactors = FALSE)
  
### polygenic model
M <- solarPolygenic(bmi ~ 1, pdat)

## assoc. model
genocov.files <- 
snplists.files <- c(file.path(gdir1, "snp.geno-list"), file.path(gdir2, "snp.geno-list"))

A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files, snplists.files = snplists.files)


