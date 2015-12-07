
context("solarAssoc in parallel")

#----------------------------
# input data: `genocov.files`
#----------------------------
test_that("input data parameters 2 `genocov.files` & 2 `snplists.files`", {
  data(dat50)
  
  dir <- package.file("inst/extdata/solarAssoc/", package = "solarius")
  genocov.files <- file.path(dir, "snp.genocov")
  snplists.files <- file.path(dir, "snp.geno-list")

  mod1 <- solarAssoc(trait ~ age + sex, phenodata, genocov.files = genocov.files, snplists.files = snplists.files)
  mod2 <- solarAssoc(trait ~ age + sex, phenodata, genocov.files = genocov.files, snplists.files = snplists.files, cores = 2)
  
  expect_true(modelParCPUtime(mod1) > modelParCPUtime(mod2))
})
