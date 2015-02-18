### inc
library(devtools)

#library(solarius)
load_all("~/git/ugcd/solarius")

#library(gait)
load_all("~/git/ugcd/gait")

### par
cores <- 64

### var
gait1.snpfiles <- gait1.snpfiles(chr = 1, num.snpdirs = 2)
#gait1.snpfiles <- gait1.snpfiles(chr = 22)
#gait1.snpfiles <- gait1.snpfiles(chr = 1)
#gait1.snpfiles <- gait1.snpfiles()
#gait1.snpfiles <- gait1.snpfiles(chr = 21:22)

# read phen. data
pdat <- gait1.phen()

pdat <- mutate(pdat,
  ln_bmi = log(bmi),
  tr_bmi = 6.1 * ln_bmi)
  
### polygenic model
#M <- solarPolygenic(bmi ~ 1, pdat)
M1 <- solarPolygenic(tr_bmi ~ AGE, pdat, covtest = TRUE)
M3 <- solarPolygenic(aff ~ AGE, pdat, covtest = TRUE)

## assoc. model
#A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files[1], snplists.files = snplists.files[1], snpind = 1:4)
#A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files[1], snplists.files = snplists.files[1], cores = 2)
#A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files, snplists.files = snplists.files)
#A <- solarAssoc(bmi ~ 1, pdat, genocov.files = genocov.files, snplists.files = snplists.files, snpmap.files = snpmap.files, cores = 2)

A1 <- solarAssoc(tr_bmi ~ 1, pdat, genocov.files = gait1.snpfiles$genocov.files, snplists.files = gait1.snpfiles$snplists.files, snpmap.files = gait1.snpfiles$snpmap.files, cores = cores, verbose = 1)

stop()

A2 <- solarAssoc(tr_bmi ~ AGE, pdat, genocov.files = gait1.snpfiles$genocov.files, snplists.files = gait1.snpfiles$snplists.files, snpmap.files = gait1.snpfiles$snpmap.files, cores = cores)

A3 <- solarAssoc(aff ~ AGE, pdat, genocov.files = gait1.snpfiles$genocov.files, snplists.files = gait1.snpfiles$snplists.files, snpmap.files = gait1.snpfiles$snpmap.files, cores = cores)

save(A1, A2, A3, file = "gait1.bmi.A.RData")
