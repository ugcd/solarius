---
layout: tutorial
title: Test covariates
title_id: test_covariates
---





  




~~~ r
mod1 <- solarPolygenic(trait1 ~ age + sex, dat30, screen = TRUE)
mod1$cf
~~~



~~~
## data frame with 0 columns and 0 rows
~~~



~~~ r
mod1$solar$cmd
~~~



~~~
## [1] "trait trait1"                  "covariate age sex"            
## [3] ""                              "polygenic  -prob 0.05 -screen"
~~~



~~~ r
mod2 <- solarPolygenic(trait1 ~ age + sex, dat30, screen = TRUE,
  alpha = 0.5)
mod2$cf
~~~



~~~
## [1] "Error : length(vals) == ncov + 1 is not TRUE\n"
## attr(,"class")
## [1] "try-error"
## attr(,"condition")
## <simpleError: length(vals) == ncov + 1 is not TRUE>
~~~


