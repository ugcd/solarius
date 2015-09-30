#library(gait)
load_all("~/git/ugcd/gait")

dir <- tempfile(pattern = "solar-multipoint")
dir <- "solar"

### gait phenotypes
traits0 <- gait1.traits.cascade()
traits <- paste0("tr1_", traits0)

dat <- gait1.phen(transform = "tr1", traits = traits[1], id.ibd = TRUE)

### linkage 
mibddir <- gait1.mibddir()

### export data
df2solar(dat, dir) 

### run solar 1
cmd <- c(
  "pedigree load dat.ped", 
  "phen load dat.phe",
  "model new", "trait tr1_FVII", "polygenic")
ret <- solar(cmd, dir)

### run solar 2
cmd <- c("load model tr1_FVII/null0.mod",
  paste("mibddir", mibddir), 
  "chromosome 1", "interval 5", 
  "multipoint -overwrite")

ret <- solar(cmd, dir)

### clean
#unlink(dir, recursive = TRUE)
