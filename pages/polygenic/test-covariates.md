---
layout: tutorial
title: Test covariates
title_id: test_covariates
---





  



### LRT

`SOLAR` performs likelihood ratio test (LRT) 
to evaluate the significance of covariates in a model.
`covtest` argument says to conduct the LRT tests for all covariates.
This option is disabled by default (to save calculation time).


~~~ r
mod1 <- solarPolygenic(trait1 ~ age + sex, dat30)
mod1$cf
~~~



~~~
##   covariate   Estimate      SE Chi pval
## 1       age  0.0004591 0.01484  NA   NA
## 2       sex -0.4559509 0.31251  NA   NA
~~~


For the next model the test results are collected into `cf` slot
of the model object.


~~~ r
mod2 <- solarPolygenic(trait1 ~ age + sex, dat30, covtest = TRUE)
mod2$cf
~~~



~~~
##   covariate   Estimate      SE   Chi   pval
## 1       age  0.0004591 0.01484 0.001 0.9753
## 2       sex -0.4559509 0.31250 2.118 0.1455
~~~


The `SOLAR` command was the following.


~~~ r
mod2$solar$cmd
~~~



~~~
## [1] "trait trait1"                      
## [2] "covariate age sex"                 
## [3] ""                                  
## [4] "polygenic  -prob 0.05 -screen -all"
~~~


In particular, `-screen -all` options for `polygenic` command does the job.
These two options say to screen the covariates, although they will be all saved (not screened).
That leads to the tests without covariate screening.

### Model files

`SOLAR` files generated to compute the model are stored.


~~~ r
names(mod2$solar$files$model)
~~~



~~~
##  [1] "last.mod"                  "noage.mod"                
##  [3] "noage.out"                 "nocovar.mod"              
##  [5] "nocovar.out"               "nosex.mod"                
##  [7] "nosex.out"                 "null0.mod"                
##  [9] "null0.out"                 "out.covariate"            
## [11] "out.globals"               "out.param.univar"         
## [13] "out.varcomp.univar"        "p0.mod"                   
## [15] "p0.out"                    "polygenic.logs.out"       
## [17] "polygenic.out"             "polygenic.residuals"      
## [19] "polygenic.residuals.stats" "poly.mod"                 
## [21] "poly.out"                  "s0.mod"                   
## [23] "s0.out"                    "spor.mod"                 
## [25] "spor.out"
~~~


Files `noage.mod` and `nosex.mod` are two polygenic models without one of the two covariates,
which in turn were compared to the null model with all covariates to get the LRT statistics.
