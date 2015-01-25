
context("kinship matrix")

test_that("solarKinship2", {
  data(dat30)
  
  kin2 <- solarKinship2(dat30)
  kin <- kin2 / 2

  dat30.subset <- subset(dat30, select = c("id", "trait1", "sex"))
  #dat30.subset <- mutate(dat30.subset,
  #  famid = 0, fa = 0, mo = 0)
  #dat30.subset <- dat30
    
  mod1 <- solarPolygenic(trait1 ~ 1, dat30)
  mod2 <- solarPolygenic(trait1 ~ 1, dat30.subset, kinship = kin)
  
  h2r1 <- with(mod1$vcf, Var[varcomp == "h2r"])
  h2r2 <- with(mod2$vcf, Var[varcomp == "h2r"])

  expect_equal(h2r1, h2r2)
})

test_that("two custom kinship matrices", {
  data(dat30)
  
  kin2 <- solarKinship2(dat30)
  kin <- kin2 / 2
  
  mod1 <- solarPolygenic(trait1 ~ 1, dat30, kinship = kin)
  mod2 <- solarPolygenic(trait1 ~ 1, dat30, kinship = kin2)
  
  h2r1 <- with(mod1$vcf, Var[varcomp == "h2r"])
  h2r2 <- with(mod2$vcf, Var[varcomp == "h2r"])

  expect_more_than(h2r1, h2r2)
})
