
context("solarMultipoint")

# basic examples
test_that("basic example on dat30", {
  dat <- loadMulticPhen()
  mibddir <- package.file("extdata", "solarOutput", "solarMibds", package = "solarius")  
  
  chr <- 5
  num.files <- length(list.files(mibddir, paste0("mibd.", chr)))

  mod <- solarMultipoint(trait1 ~ 1, dat, mibddir = mibddir, chr = chr)
  
  expect_equal(num.files, nrow(mod$lodf))
  expect_true(all(mod$lodf$LOD > 10))
})

test_that("CSV IBD matices", {
  dat <- loadMulticPhen()
  mibddir <- package.file("extdata", "solarOutput", "solarMibdsCsv", package = "solarius")  

  chr <- 5
  num.files <- length(list.files(mibddir, paste0("mibd.", chr)))
  
  mod <- solarMultipoint(trait1 ~ 1, dat, mibddir = mibddir, chr = chr)
  
  expect_equal(num.files, nrow(mod$lodf))
  expect_true(all(mod$lodf$LOD > 10))
})

# multipoint options
test_that("interval", {
  dat <- loadMulticPhen()
  mibddir <- package.file("extdata", "solarOutput", "solarMibdsCsv", package = "solarius")  

  mod <- solarMultipoint(trait1 ~ 1, dat, mibddir = mibddir, chr = 5, interval = 5, multipoint.settings = "finemap off")
  
  expect_equal(nrow(mod$lodf), 2)
})

