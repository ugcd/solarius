### inc
#library(solarius)
load_all("~/git/ugcd/solarius")

library(gait1)

### par
cores <- 64

### parallel
parallel <- (cores > 1)
if(parallel) {
  ret <- require(doMC)
  if(!ret) {
    stop("`doMC` package is required for parallel calculations")
  }
  doMC::registerDoMC(cores)
}
  

### var
gait1.snpfiles <- gait1.snpfiles()
snpmap.files <- gait1.snpfiles$snpmap.files

out <- llply(snpmap.files, function(x)
  list(file = x, result = try({
    read_map(x)
  })), .parallel = parallel)

### print
cl <- laply(out, function(x) class(x$result)[1])
nrows <- laply(out, function(x) nrow(x$result))

#> table(nrows)
#nrows
#  0  57  94 138 193 220 256 304 320 346 367 368 376 380 404 415 437 450 458 468 
#  1   1   1   1   2   1   1   1   1   2   1   1   1   1   1   1   1   1   1   1 
#499 500 501 
# 14 589   1 

