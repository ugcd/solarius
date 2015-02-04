
context("solarMultipoint")

# basic example
test_that("basic example on dat30", {
  data(dat30)

  mibddir <- package.file("extdata", "solarOutput", "solarMibds", package = "solarius")  
  mod <- solarMultipoint(trait1 ~ 1, dat30)
  
})


