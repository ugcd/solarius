### inc
library(solarius)

### we need the latest version that gives Z/pvalZ
stopifnot(packageVersion("solarius") >= "0.3.2")

### data
data(dat30)

### run bi-variate polygenic model
m2 <- solarPolygenic(trait1 + trait2 ~ 1, dat30)

#> m2$vcf
#      varcomp  Estimate         SE         Z        pvalZ
#1 h2r(trait1) 0.8218823 0.10532575  7.803242 5.215258e-03
#2  e2(trait1) 0.1781177 0.10532575  1.691112 1.934544e-01
#3 h2r(trait2) 0.6270026 0.11581068  5.414031 1.997553e-02
#4  e2(trait2) 0.3729974 0.11581068  3.220751 7.271026e-02
#5        rhog 0.9728759 0.03744417 25.982039 3.446085e-07
#6        rhoe 0.4120487 0.19693793  2.092277 1.480453e-01
