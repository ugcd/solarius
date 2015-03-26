### inc
library(GWASTools)

### par
dir.plink <- "inst/extdata/solarAssoc/plink/"
file.ped <- file.path(dir.plink, "dat50.ped")
file.map <- file.path(dir.plink, "dat50.map")

file.ncdf <- "dat50.ncdf"
scan.annot <- "dat50.scan"
snp.annot <- "dat50.snp"

ret <- plinkToNcdf(file.ped, file.map, 66, 
  file.ncdf, scan.annot, snp.annot)

### test ncdf
nc <- NcdfGenotypeReader(file.ncdf)

