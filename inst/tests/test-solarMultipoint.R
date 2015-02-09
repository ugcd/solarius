
context("solarMultipoint")

# basic example
test_that("basic example on dat30", {
  dat <- loadMulticPhen()
  mibddir <- package.file("extdata", "solarOutput", "solarMibds", package = "solarius")  

  num.files <- length(list.files(mibddir, "mibd"))

  mod <- solarMultipoint(trait1 ~ 1, dat, mibddir = mibddir)
  
  expect_equal(num.files, nrow(mod$lodf))
  expect_true(all(mod$lodf$LOD > 10))
})

# basic example
test_that("CSV IBD matices", {
  dat <- loadMulticPhen()
  mibddir <- package.file("extdata", "solarOutput", "solarMibdsCsv", package = "solarius")  

  num.files <- length(list.files(mibddir, "mibd"))
  
  mod <- solarMultipoint(trait1 ~ 1, dat, mibddir = mibddir)
  
  expect_equal(num.files, nrow(mod$lodf))
  expect_true(all(mod$lodf$LOD > 10))
})
