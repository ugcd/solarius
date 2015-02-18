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
#L1 <- solarMultipoint(bmi ~ 1, dat, mibddir = mibddir, chr = 1:22, interval = 20, multipoint.settings = "finemap off", verbose = 1, cores = cores)

#L1 <- solarMultipoint(bmi ~ AGE, dat, mibddir = mibddir, chr = 1:22, interval = 5, multipoint.options = "3", verbose = 1, cores = cores)
#L2 <- solarMultipoint(aff ~ AGE, dat, mibddir = mibddir, chr = 1:22, interval = 5, multipoint.options = "3", verbose = 1, cores = cores)
#L12 <- solarMultipoint(aff + bmi ~ AGE, dat, mibddir = mibddir, chr = 1:22, interval = 5, multipoint.options = "3", verbose = 1, cores = cores)

L1 <- solarMultipoint(tr_bmi ~ AGE, dat, mibddir = mibddir, chr = 1:22, interval = 5, verbose = 1, cores = cores)
L2 <- solarMultipoint(aff ~ AGE, dat, mibddir = mibddir, chr = 1:22, interval = 5, verbose = 1, cores = cores)
L3 <- solarMultipoint(tr_FXI ~ AGE, dat, mibddir = mibddir, chr = 1:22, interval = 5, verbose = 1, cores = cores)

save(L1, L2, L3, file = "gait1.L.univar.RData")
