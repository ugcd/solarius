---
layout: tutorial
title: Covariate formats
title_id: covariate_formats
---





  



`SOLAR` encodes covariartes in a special format,
which is described in [manual page](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html#covariate)
for `covariate` command.
Special rules are concerned with interaction terms, quadratic/cubic/etc variables
and [trait-specific covariates]({{ site.baseurl }}/pages/bivariate/trait-specific-covariates.html).

Some examples of `covariate` commands are given in the following table
(copied from `covariate` [manual page](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html#covariate)).

| `SOLAR` command |  Comment |
|-----------------|----------|
| `covariate age` | covariate age |
| `covariate age*sex` | age and sex interaction (only) |
| `covariate age*diabet*diameds` | 3-way interaction |
| `covariate age^2` | age squared |
| `covariate age^1,2` | shorthand for: age age^2 |
| `covariate age#diabet` | shorthand for: age diabet age*diabet |
| `covariate age^1,2,3#sex` | shorthand for: sex age age*sex age^2 age^2*sex age^3 age^3*sex |
| `covariate sex age(q1) age*sex(q3)` | trait-specific covariates |
{: class="table"}

`solarius` package provides two alternative interfaces to introduce covariates:
`formula` argument or two arguments `traits` and `covlist`.

### Interaction terms

The next three models are equvalent, and all introduce covariates
`age`, `sex` and their interaction effect. By looking at the slot `cf` of the model object,
one can ensure that the three covariate terms are presented
and their p-values are identical.


~~~ r
mod1 <- solarPolygenic(trait1 ~ age + sex + age*sex, data = dat30, covtest = TRUE)
mod1$cf
~~~



~~~
##   covariate Estimate      SE    Chi   pval
## 1       age -0.02009 0.02357 0.7238 0.3949
## 2       sex -0.45079 0.31118 2.0887 0.1484
## 3   age*sex  0.03469 0.03104 1.2471 0.2641
~~~



~~~ r
mod2 <- solarPolygenic(traits = "trait1", covlist = c("age", "sex", "age*sex"), 
  data = dat30, covtest = TRUE)
mod2$cf
~~~



~~~
##   covariate Estimate      SE    Chi   pval
## 1       age -0.02009 0.02357 0.7238 0.3949
## 2       sex -0.45079 0.31118 2.0887 0.1484
## 3   age*sex  0.03469 0.03104 1.2471 0.2641
~~~



~~~ r
mod3 <- solarPolygenic(traits = "trait1", covlist = c("age#sex"), data = dat30, 
  covtest = TRUE)
mod3$cf
~~~



~~~
##   covariate Estimate      SE    Chi   pval
## 1       age -0.02009 0.02357 0.7238 0.3949
## 2       sex -0.45079 0.31118 2.0887 0.1484
## 3   age*sex  0.03469 0.03104 1.2471 0.2641
~~~


If one encodes covariates in a form `age*sex`, `SOLAR` will put only the interaction term
(this behaviour is different from, for example, `lm` model in R).


~~~ r
mod4 <- solarPolygenic(trait1 ~ age*sex, data = dat30, covtest = TRUE)
mod4$cf
~~~



~~~
##   covariate Estimate      SE    Chi   pval
## 1   age*sex  0.01253 0.01952 0.4136 0.5202
~~~


The resulted model `mod4` does not make sense, as the interaction term 
is presented without `age` and `sex` covariates.

Once can see the actual command passed to `SOLAR`.


~~~ r
mod1$solar$cmd
~~~



~~~
## [1] "trait trait1"                      
## [2] "covariate age sex age*sex"         
## [3] ""                                  
## [4] "polygenic  -prob 0.05 -screen -all"
~~~

