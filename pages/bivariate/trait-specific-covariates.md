---
layout: tutorial
title: Trait-specific covariates
title_id: trait_specific_cov
---





  



Formula interface in `solarPolygenic` is used differently than in standard functions like `lm`.
The variable names are extracted from left-hand and right-hand sides of the formula argument,
checked for existence in `data` columns and then passed to `SOLAR`.
Thus, formula is such that `SOLAR` likes it.
That allows to specify covariates in a trait-specific manner like `sex(trait1)`.

### Common covariates

`mod1` model is created with a common formula format,
that means `sex` covariate is given for both traits `trait1` and `trait2`.


~~~ r
mod1 <- solarPolygenic(trait1 + trait2 ~ sex, dat30)
~~~


### Trait-specific covariates

Imagine that `sex` is the only significant covariate for `trait1`,
and `age` is the only significant covariate for `trait2`.

| trait      |  covariates |
|------------|-------------|
| trait1     |      sex    |
| tarit2     |     age     |
{: class="table"}

Covariates in `mod2` model  are trait-specific.


~~~ r
mod2 <- solarPolygenic(trait1 + trait2 ~ sex(trait1) + age(trait2), dat30)
~~~


A mix of common and trait-specific covariates is also possible.

| trait      |  common covariates | specific covariates |
|------------|--------------------|---------------------|
| trait1     |      sex           |                     |
| tarit2     |      sex           | age                 |
{: class="table"}



~~~ r
mod3 <- solarPolygenic(trait1 + trait2 ~ sex + age(trait2), dat30)
~~~



### `traits` and `covlist` arguments


~~~ r
args(solarPolygenic)
~~~



~~~
## function (formula, data, dir, traits, covlist = "1", covtest = FALSE, 
##     screen = FALSE, household = FALSE, alpha = 0.05, polygenic.settings = "", 
##     polygenic.options = "", verbose = 0, ...) 
## NULL
~~~



~~~ r
mod2.par <- solarPolygenic(traits = c("trait1", "trait2"), 
  covlist = c("sex(trait1)", "age(trait2)"), data = dat30)
~~~


Covariates for `mod2.par` model  are trait-specific.
