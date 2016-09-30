# Learn SOLAR command simqtl
Andrey Ziyatdinov  
`r Sys.Date()`  




```r
library(plyr)
library(ggplot2)

library(pander)

library(data.table)
```


```r
theme_set(theme_light())

panderOptions('table.style', 'rmarkdown')

panderOptions('table.split.table', Inf)
panderOptions('knitr.auto.asis', FALSE)
```

## Load GAIT1 data


```r
load_all("~/git/ugcd/solarius")
load_all("~/git/ugcd/gait")
phen <- gait1.phen(traits = "APTT")
```

## Command h2power

Parameters

* `-data`: Exclude individuals from the power calculation who are missing data for phenotype `<fieldname>`.
* `-nreps`: Perform `<nreps>` simulations at each grid point. The default number of replicates is `100`.
* `-overwrite (or -ov)`: Overwrite the results of a previous power calculation.
                                   

```r
dir <- "solar" 
df2solar(phen, dir)

cmd <- "h2power -data AGE -nreps 5 -seed 1 -ov -grid {0 0.99 0.1} -nosmooth"
ret <- solar(cmd, dir)

### read data
#tab <- fread("solar/h2power.out")

### plot
#p <- ggplot(tab, aes(V1, V2)) + geom_line(color = "gray40") + geom_point() + 
#  labs(x = "Simulated h2", y = "Power", title = "Power simulation")
```
