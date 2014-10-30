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
##   1.020   0.268   2.592
~~~



~~~ r
system.time(mod <- solarAssoc(traits = "trait", data = phenodata, snpdata = genodata, cores = 2))
~~~



~~~
##    user  system elapsed 
##   0.932   0.184   2.079
~~~


