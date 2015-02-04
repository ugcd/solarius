### par
dir <- "solar"
mibddir <- "solarMibds"

### data set from multic package
library(solarius)

dir.create(dir)

files <- list.files(package.file("extdata", "solarOutput", package = "solarius"), full.names = TRUE)
file.copy(files, dir, recursive = TRUE)

### run solar 1
cmd <- c(
  "pedigree load simulated.ped", 
  "phen load simulated.phen",
  "model new", "trait trait1", "polygenic")
ret <- solar(cmd, dir)

### run solar 2
cmd <- c("load model trait1/null0",
  paste("mibddir", mibddir), 
  "chromosome all", "interval 5", 
  "multipoint -overwrite")

ret <- solar(cmd, dir)

print(ret)
