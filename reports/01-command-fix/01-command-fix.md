# SOLAR command fix
Andrey Ziyatdinov  
`r Sys.Date()`  


## Include


```r
library(solarius)
```

## Parameters


```r
dir1 <- "solar1"
dir2 <- "solar2"
dir3 <- "solar3"
```


```r
dir.create(dir1, showWarnings = FALSE)
dir.create(dir2, showWarnings = FALSE)
dir.create(dir3, showWarnings = FALSE)
```


## Example 1


```r
dat <- loadMulticPhen()
df2solar(dat, dir1)

cmd1 <- c("load pedigree dat.ped", 
  "load phenotypes dat.phe",
  "trait trait1",
  "covariate",
  "polygenic",
  "quit")

ret1 <- solar(cmd1, dir1)
grep("H2r", ret1, value = TRUE)
```

```
## [1] "    *** H2r in polygenic model is 0.8861313"              
## [2] "    *** Determining significance of H2r"                  
## [3] "\t\t\t H2r is 0.8861313  p = 1.6810136e-80  (Significant)"
## [4] "\t       H2r Std. Error:  0.0343709"
```

```r
cmd2 <- c("load model trait1/null0",
  "covariate age",
  "polygenic",
  "quit")
ret2 <- solar(cmd2, dir1)
grep("H2r", ret2, value = TRUE)
```

```
## [1] "    *** H2r in polygenic model is 0.8870277"             
## [2] "    *** Determining significance of H2r"                 
## [3] "\t\t\t H2r is 0.8870277  p = 1.989064e-80  (Significant)"
## [4] "\t       H2r Std. Error:  0.0343318"
```

## Example 2

Compute two models:

* `trait1/null0`: no covariates, free `h2r`
* `constrained.mod`: `age` covariate, constrained `h2r` to that value in the previous model


```r
dat <- loadMulticPhen()
df2solar(dat, dir2)

cmd1 <- c("load pedigree dat.ped", 
  "load phenotypes dat.phe",
  "trait trait1",
  "covariate",
  "polygenic",
  "quit")

ret1 <- solar(cmd1, dir2)
grep("H2r", ret1, value = TRUE)
```

```
## [1] "    *** H2r in polygenic model is 0.8861313"              
## [2] "    *** Determining significance of H2r"                  
## [3] "\t\t\t H2r is 0.8861313  p = 1.6810136e-80  (Significant)"
## [4] "\t       H2r Std. Error:  0.0343709"
```

```r
cmd2 <- c("load model trait1/null0",
  "covariate age",
  "fix h2r",
  "maximize", "save model trait1/constrained",
  "quit")
ret2 <- solar(cmd2, dir2)
grep("H2r", ret2, value = TRUE)
```

```
## character(0)
```

Compare likelihoods:


```r
tail(readLines("solar2/trait1/null0.mod"), 1)
```

```
## [1] "loglike set -1491.576753"
```

```r
tail(readLines("solar2/trait1/constrained.mod"), 1)
```

```
## [1] "loglike set -1491.133433"
```

Make sure that the first likelihood is the same as that computed by `solarPolygenic` function:


```r
mod1 <- solarPolygenic(trait1 ~ 1, dat)
mod1$lf
```

```
##       model    loglik
## 1  sporadic -1671.400
## 2 polygenic -1491.577
```

Compare h2r:


```r
grep("h2r", readLines("solar2/trait1/null0.mod"), value = TRUE)[1]
```

```
## [1] "parameter      h2r = 0.8861313186409259 Lower 0           Upper 1         "
```

```r
grep("h2r", readLines("solar2/trait1/constrained.mod"), value = TRUE)[1]
```

```
## [1] "parameter      h2r = 0.8861313186409259 Lower 0           Upper 1         "
```

## Example 3

Compute two models:

* `trait1.trait2/null0`: no covariates, free variance components
* `constrained.mod`: `age` covariate, constrained free variance components


```r
dat <- loadMulticPhen()

data(dat30)
dat <- dat30

df2solar(dat, dir3)

cmd0 <- c("load pedigree dat.ped", "load phenotypes dat.phe",
  "trait trait1 trait2", "covariate age",
  "polygenic", 
  "quit")

t0 <- system.time(ret0 <- solar(cmd0, dir3))

cmd1 <- c("load model trait1.trait2/null0",
  "covariate age sex",
  "polymod", "maximize", "save model trait1.trait2/constrained1",
  "quit")

t1 <- system.time(ret1 <- solar(cmd1, dir3))

cmd2 <- c("load model trait1.trait2/null0",
  "covariate age sex",
  "constraint delete_all",
  "fix h2r(trait1)", "fix h2r(trait2)",
  "fix e2(trait1)", "fix e2(trait2)",  
  "fix rhoe", "fix rhog",
  "fix sd(trait1)", "fix sd(trait2)",
  "option StandErr 0",
  "maximize", "save model trait1.trait2/constrained2",
  "quit")

t2 <- system.time(ret2 <- solar(cmd2, dir3))

cmd3 <- c("load model trait1.trait2/null0",
  "covariate age sex",
  "constraint delete_all",
  "fix h2r(trait1)", "fix h2r(trait2)",
  "fix e2(trait1)", "fix e2(trait2)",  
  "fix rhoe", "fix rhog",
  "fix mean(trait1)", "fix mean(trait2)",  
  "fix sd(trait1)", "fix sd(trait2)",  
  "fix bage(trait1)", "fix bage(trait2)",  
  "option StandErr 0",
  "maximize", "save model trait1.trait2/constrained3",
  "quit")

t3 <- system.time(ret3 <- solar(cmd3, dir3))

cmd4 <- c("load model trait1.trait2/null0",
  "covariate age sex",
  "constraint delete_all",
  "fix h2r(trait1)", "fix h2r(trait2)",
  "fix e2(trait1)", "fix e2(trait2)",  
  "fix rhoe", "fix rhog",
  "fix mean(trait1)", "fix mean(trait2)",  
  "fix sd(trait1)", "fix sd(trait2)",  
  "fix bage(trait1)", "fix bage(trait2)",  
  "option MaxIter 1", "option StandErr 0",
  #"option MaxStep 0", "option MaxCliffs 0",
  "maximize", "save model trait1.trait2/constrained4",
  "quit")

t4 <- system.time(ret4 <- solar(cmd4, dir3))
```


```r
c(t0[3], t1[3], t2[3], t3[3], t4[3])
```

```
## elapsed elapsed elapsed elapsed elapsed 
##   3.334   3.301   0.740   0.393   0.150
```


```r
round(c(t0[3], t1[3], t2[3], t3[3], t4[3]) / t3[3], 2)
```

```
## elapsed elapsed elapsed elapsed elapsed 
##    8.48    8.40    1.88    1.00    0.38
```



```r
round(c(t0[3], t1[3], t2[3], t3[3], t4[3]) / t4[3], 2)
```

```
## elapsed elapsed elapsed elapsed elapsed 
##   22.23   22.01    4.93    2.62    1.00
```
