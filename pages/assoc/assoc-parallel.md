---
layout: tutorial
title: Parallelization
title_id: assoc_parallel
---





  





~~~ r
data(dat50)

system.time(mod <- solarAssoc(traits = "trait", data = phenodata, snpdata = genodata, cores = 1))
~~~



~~~
##    user  system elapsed 
##   1.092   0.176   2.279
~~~



~~~ r
system.time(mod <- solarAssoc(traits = "trait", data = phenodata, snpdata = genodata, cores = 2))
~~~



~~~
##    user  system elapsed 
##   0.884   0.176   1.862
~~~


