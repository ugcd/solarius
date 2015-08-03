# Association with multiple traits in SOLAR
Andrey Ziyatdinov  
`r Sys.Date()`  

# References

* http://helix.nih.gov/Documentation/solar-6.6.2-doc/09.chapter.html, Section 9.2.1.2 Multivariate Mu 

# Parameters


```r
dir <- "solar"
```

# Include


```r
library(devtools)
```

## Load


```r
load_all("~/git/ugcd/solarius/")
```

```
## Loading solarius
```

# Data


```r
data(dat30, package = "solarius")
```

# Polygenic 

## Model 1


```r
mod1 <- solarPolygenic(trait1 + trait2 ~ age, dat30, dir = dir)
```

## Model 2


```r
cmd1 <- c("load model trait1.trait2/null0",
  "define age_i = age",
  "mu = mu + {t2*(<bage_i(trait2)>*age_i)}",
  "maximize",
  "save model trait1.trait2/custom1")

ret1 <- solar(cmd1, dir)

cmd2 <- c(
  "load model trait1.trait2/spor",
  "set loglik_0 [loglike]",
  "puts \"loglik_0 = $loglik_0\"",
  "load model trait1.trait2/null0",
  "set loglik_1 [loglike]",
  "puts \"loglik_1 = $loglik_1\"",
  "define age_i = age",
  "covariate sex age_i(trait2)",
  "polymod", 
  "maximize",
  "set loglik_2 [loglike]",
  "puts \"loglik_2 = $loglik_2\"",
  "save model trait1.trait2/custom2") 

ret2 <- solar(cmd2, dir)  
```


```r
grep("loglik_", ret2, value = TRUE)
```

```
## [1] "loglik_0 = -383.409734" "loglik_1 = -362.712486"
## [3] "loglik_2 = -361.499237"
```

# Association

## Assoc 1  


```r
assoc1 <- solarAssoc(trait1 + trait2 ~ age, dat30, snpcovdata = genocovdat30[, 1:2], 
  dir = dir, 
  assoc.options = "-saveall")
```

`SOLAR` command:


```r
assoc1$assoc$solar$cmd
```

```
## [[1]]
## [1] "load model trait1.trait2/null0.mod"                                    
## [2] "outdir assoc"                                                          
## [3] "mga -files snp.genocov -snplists snp.geno-list -out assoc.out -saveall"
```
