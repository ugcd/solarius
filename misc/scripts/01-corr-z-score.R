### inc
library(solarius)

### data
data(dat30)

### run 1: SOLAR is parametrized to test rho by LRT
t1 <- system.time({
  m1 <- solarPolygenic(trait1 + trait2 ~ 1, dat30, polygenic.options = '-testrhoe -testrhog')
})

#> m1$vcf
#      varcomp  Estimate         SE    zscore
# ...
#5        rhog 0.9728759 0.03744417 25.982039
#6        rhoe 0.4120487 0.19693793  2.092277

#> m1$lf
#      model    loglik       Chi deg         pval
# ...
#3     rhoe0 -364.9032  2.151806   1 1.424023e-01
#4     rhog0 -381.7010 35.747400   1 2.246316e-09
# ...


### run 2: SOLAR just fits data onces for the full model (no fitting of alternative models, no LRT)
t2 <- system.time({
  m2 <- solarPolygenic(trait1 + trait2 ~ 1, dat30)
})

# derive p-values of `rhog` & `rhoe` using Z-score
# - at the end, the p-values based on Z-score are good approximation to that in `m1$lf`
# - note: it is not possible to compute p-value for `rhog1
ztab <- subset(m2$vcf, varcomp %in% c("rhog", "rhoe"))

ztab <- within(ztab, {
  pval_zscore <- pchisq(zscore, df = 1, lower.tail = FALSE)
})

#> ztab
#  varcomp  Estimate         SE    zscore  pval_zscore
#5    rhog 0.9728759 0.03744417 25.982039 3.446085e-07
#6    rhoe 0.4120487 0.19693793  2.092277 1.480453e-01

### compare computation times
#> t1
#   user  system elapsed
#  1.829   0.185   3.397
#> t2
#   user  system elapsed
#  0.851   0.126   1.520

