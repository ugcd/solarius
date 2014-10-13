---
layout: tutorial
title: Polygenic model (bivariate)
title_id: polygenic_bivar
---




~~~ r
library(solarius)
~~~



~~~
## Loading required package: plyr
~~~



~~~ r
mod <- solarPolygenic(trait1 + trait2 ~ 1, dat30)
~~~



~~~ r
mod
~~~



~~~
## 
## Call: solarPolygenic(formula = trait1 + trait2 ~ 1, data = dat30)
## 
## File polygenic.out:
## 	Pedigree:    dat.ped 
## 	Phenotypes:  dat.phe 
## 	Trait:       trait1 trait2         Individuals:  174 
##  
## 			 H2r(trait1) is 0.8218823   
## 	       H2r(trait1) Std. Error:  0.1053258 
##  
## 			 H2r(trait2) is 0.6270026   
## 	       H2r(trait2) Std. Error:  0.1158107 
##  
## 			 RhoE is 0.4120487   
## 	       RhoE Std. Error:  0.1969379 
##  
## 			 RhoG is 0.9728759 
## 	       RhoG Std. Error:  0.0374442 
##  
## 	       Derived Estimate of RhoP is 0.8045957 
##  
##  
## 	Loglikelihoods and chi's are in trait1.trait2/polygenic.logs.out 
## 	Best model is named poly and null0 
## 	Final models are named poly, spor
~~~



