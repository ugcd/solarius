
context("solarMultipoint")

# basic example
test_that("basic example on dat30", {
  dat <- loadMulticPhen()
  mibddir <- package.file("extdata", "solarOutput", "solarMibds", package = "solarius")  

  mod <- solarMultipoint(trait1 ~ 1, dat, mibddir = mibddir)
  
})

# basic example
test_that("CSV IBD matices", {
  dat <- loadMulticPhen()
  mibddir <- package.file("extdata", "solarOutput", "solarIDMibds", package = "solarius")  

  mod <- solarMultipoint(trait1 ~ 1, dat, mibddir = mibddir)
  
})
