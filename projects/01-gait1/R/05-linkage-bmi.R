### inc
library(solarius)
#load_all("~/git/ugcd/solarius")

library(gait)

### par
cores <- 8

### var
dat  <- gait1.phen()
mibddir <- gait1.mibddir()

dat <- mutate(dat,
  ln_bmi = log(bmi),
  tr_bmi = 6.1 * ln_bmi)
  
### linkage
L <- solarMultipoint(bmi ~ AGE, dat, mibddir = mibddir, chr = 13, interval = "10 100-140", multipoint.settings = "finemap off")

### save
#save(L1, file = "gait1.bmi.L.RData")
