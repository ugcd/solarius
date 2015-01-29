library(solarius)

### par
# phenotype dir
#pdir <- "/home/datasets/GAIT1/GWAS/SFBR"
pdir <- "/home/andrey/Datasets/GAIT1/SFBR/subset"

phefile <- file.path(pdir, "gait1.phe")
pedfile <- file.path(pdir, "gait1.ped")

gdir1 <- file.path(pdir, "Impute/c1.1.500/")
gdir2 <- file.path(pdir, "Impute/c1.501.1000/")

### read phen. data
pdat <- read.table(phefile, header = TRUE,
  stringsAsFactors = FALSE)

# re-read `id` field as character
tab <- read.table(phefile, header = TRUE, colClasses = "character")
pdat <- within(pdat, {
  id <- tab[, "id"]
  FA <- tab[, "FA"]
  MO <- tab[, "MO"]
  
  FA[is.na(FA)] <- "0"
  MO[is.na(MO)] <- "0"
})  
  
pdat <- subset(pdat, select = head(colnames(pdat), 13))

### polygenic model
M <- solarPolygenic(bmi ~ 1, pdat)

## assoc. model
genocov.files <- c(file.path(gdir1, "snp.genocov"), file.path(gdir2, "snp.genocov"))
snplists.files <- c(file.path(gdir1, "snp.geno-list"), file.path(gdir2, "snp.geno-list"))
snpmap.files <- c(file.path(gdir1, "map.c1.1.500"), file.path(gdir2, "map.c1.501.1000"))

#A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files[1], snplists.files = snplists.files[1], snpind = 1:4)
#A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files[1], snplists.files = snplists.files[1], cores = 2)
#A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files, snplists.files = snplists.files)
A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files, snplists.files = snplists.files, snpmap.files = snpmap.files, cores = 2)

