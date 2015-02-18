### inc
library(devtools)

#library(solarius)
load_all("~/git/ugcd/solarius")

#library(gait)
load_all("~/git/ugcd/gait")

### par
cores <- 22

mibddir <- "/home/datasets/GAIT1/mibdMatricesCsv"

# read phen. data
dat <- gait1.phen()

dat <- mutate(dat,
  ln_bmi = log(bmi),
  tr_bmi = 6.1 * ln_bmi,
  ln_FXI = log(FXII),
  tr_FXI = 5.1 * FXI_T)

## assoc. model
L12 <- solarMultipoint(aff + bmi ~ AGE, dat, mibddir = mibddir, chr = 1:22, interval = 5, verbose = 1, cores = cores)

save(L12, file = "gait1.L12.bivar.RData")
