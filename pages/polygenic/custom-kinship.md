---
layout: tutorial
title: Custom kinship matrix
title_id: custom_kinship
---





  




~~~ r
data(dat50)
~~~



~~~ r
mod <- solarPolygenic(trait ~ 1, phenodata, kinship = kin)
summary(mod)
~~~



~~~
## 
## Call: solarPolygenic(formula = trait ~ 1, data = phenodata, kinship = kin)
## 
## File polygenic.out:
## 	Pedigree:    dat.ped 
## 	Phenotypes:  dat.phe 
## 	Trait:       trait                 Individuals:  66 
##  
## 			 H2r is 0.3666309  p = 0.0027598  (Significant) 
## 	       H2r Std. Error:  0.0702535 
##  
##  
## 	Loglikelihoods and chi's are in trait/polygenic.logs.out 
## 	Best model is named poly and null0 
## 	Final models are named poly, spor 
##  
## 	Residual Kurtosis is -0.6742, within normal range 
## 
##  Loglikelihood Table:
##       model loglik
## 1  sporadic -27.77
## 2 polygenic -23.92
## 
##  Covariates Table:
## data frame with 0 columns and 0 rows
## 
##  Variance Components Table:
##   varcomp    Var      SE    pval
## 1     h2r 0.3666 0.07025 0.00276
## 2      e2 0.6334 0.07025      NA
~~~




