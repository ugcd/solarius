---
layout: tutorial
title: Polygenic model (univariate)
title_id: polygenic_univar
---





~~~ r
library(solarius)
mod <- solarPolygenic(trait1 ~ age + sex, dat30)
mod
~~~



~~~
## 
## Call: solarPolygenic(formula = trait1 ~ age + sex, data = dat30)
## 
## File polygenic.out:
## 	Pedigree:    dat.ped 
## 	Phenotypes:  dat.phe 
## 	Trait:       trait1                Individuals:  174 
##  
## 			 H2r is 0.8061621  p = 6.1167535e-10  (Significant) 
## 	       H2r Std. Error:  0.1100465 
##  
##  
## 	Proportion of Variance Due to All Final Covariates Is 
## 				  0.0330070 
##  
## 	Loglikelihoods and chi's are in trait1/polygenic.logs.out 
## 	Best model is named poly and null0 
## 	Final models are named poly, spor, nocovar 
##  
## 	Residual Kurtosis is -0.3603, within normal range 
## 
##  Covariates Table:
##   covariate   Estimate      SE Chi pval
## 1       age  0.0004591 0.01484  NA   NA
## 2       sex -0.4559509 0.31251  NA   NA
## 
##  Variance Components Table:
##   varcomp    Var   SE      pval
## 1     h2r 0.8062 0.11 6.117e-10
## 2      e2 0.1938 0.11        NA
~~~




