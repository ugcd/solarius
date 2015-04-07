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
```


```r
dir.create(dir1, showWarnings = FALSE)
dir.create(dir2, showWarnings = FALSE)
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
## [1] "parameter      h2r = 0.8861313186413069 Lower 0           Upper 1         "
```

```r
grep("h2r", readLines("solar2/trait1/constrained.mod"), value = TRUE)[1]
```

```
## [1] "parameter      h2r = 0.8861313186413069 Lower 0           Upper 1         "
```
