---
layout: tutorial
title: Custom kinship
title_id: assoc_custom_kinship
---





  




~~~ r
data(dat50)

mod1 <- solarAssoc(trait ~ 1, phenodata, snpdata = genodata)
mod2 <- solarAssoc(trait ~ 1, phenodata, snpdata = genodata, kinship = kin)
~~~



~~~ r
head(sort(mod1$snpf$pSNP))
~~~



~~~
## [1] 0.01076 0.02237 0.04008 0.05010 0.05010 0.05010
~~~



~~~ r
head(sort(mod2$snpf$pSNP))
~~~



~~~
## [1] 0.02896 0.03610 0.03694 0.03694 0.03694 0.05313
~~~

