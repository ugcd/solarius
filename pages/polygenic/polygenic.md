---
layout: tutorial
title: Polygenic model (univariate)
title_id: polygenic_univar
---




~~~ r
library(solarius)~~~



~~~
## Loading required package: plyr
~~~



~~~ r
mod <- solarPolygenic(trait1 ~ age + sex, dat30)~~~



~~~ r
mod~~~



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
~~~



