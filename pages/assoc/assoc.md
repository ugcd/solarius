---
layout: tutorial
title: Association model
title_id: assoc
---





  




~~~ r
args(solarAssoc)
~~~



~~~
## function (formula, data, dir, kinship, traits, covlist = "1", 
##     snpdata, snpformat = "012", cores = getOption("cores"), ..., 
##     verbose = 0) 
## NULL
~~~


| snpformat |  snpdata        | dat.gen        | genocov          |
|-----------|-----------------|----------------|------------------|
| "/"       | {A/A, A/T, T/T} | as is snpdata  | {0, 1, 2}        |
| "012"     | {0, 1, 2}       | {1/1, 1/2, 2/2}| {0, 1, 2}        |
| "0.1"     | [0; 2]          | skipped        | as is in snpdata |
{: class="table"}


### Example of association model


~~~ r
data(dat50)

mod <- solarAssoc(trait ~ 1, phenodata, snpdata = genodata, kinship = kin)
head(mod$snpf)
~~~



~~~
##   SNP NAv     chi    pSNP     bSNP bSNPse   Varexp
## 1  s1  66 0.16622 0.68349  0.14485      0 0.001258
## 2  s2  66 0.85145 0.35614 -0.66525      0 0.080241
## 3  s3  66 0.83979 0.35946 -0.33062      0 0.000000
## 4  s4  66 0.18220 0.66949  0.07377      0 0.000000
## 5  s5  66 0.04982 0.82338  0.34452      0 0.007852
## 6  s6  66 2.88201 0.08957 -0.24921      0 0.051719
~~~


