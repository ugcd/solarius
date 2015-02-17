## solarius

R package wrapper to SOLAR

* Vignettes `SOALR models`
  * R code [vignettes/](vignettes/)
  * hmlt output:
     1. [modelsF11.html](http://ugcd.github.io/solarius/vignettes/modelsF11.html)
     2. [models.html](http://ugcd.github.io/solarius/vignettes/models.html)

## References

* [Appendix 1. SOLAR Command Descriptions](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html)
* [SOLAR web page at txbiomedgenetics.org](http://solar.txbiomedgenetics.org/)
* [SOLAR Eclipse is a new collaboration to develop genetic analysis tools for imaging applications](http://www.nitrc.org/projects/se_linux/)

### Ideas

* do not automate things in R, which `SOLAR` has already automated
  * call `SOLAR` from system.call with `options` and `settings` parameters
* make it more R self-content and independent on other programs
  * phenotypes format as `data.frame`
  * make use of R plots like plotting pedigrees
  * make use of parallelization insfrastructure available in R
  * do not rely on tcl  scripts anymore
* get rid of `salamboR` artifacts (ancestor of `solarius`)
  * GAIT-specific functions
  * interface with other programs than `SOLAR`
  * lost version-control traces
  * dependence on old-school code from previous mantainers
  * dependence on (many) tcl scripts
* get rid of `SOLAR` artifacts
  * store models/phenos in folders/files
* make use of github infrastructure: collaborative coding, issues, gh-pages, etc

### Current status

### TODO

Polygenic model:

* extract residuals and make plots for them

Association model:

* think of which formats to support except the `SOLAR` one

Linkage model:

* make use of all linkage options availabe in `SOLAR`: second-path, adjustment of inflated scores

### Content of Software Manual

TODO:

* Polygenic model (univariate)
  * house-hold effect
  * screen covariates
  * SOLAR options (`polygenic.settings`, `polygenic.options`)
* Polygenic model (bivariate)
  * Trouble-shooting
* Association model
  * parallelization (`options(cores = 2)`)
* Linkage model

## Examples 

See tutorial [page](http://ugcd.github.io/solarius/pages/tutorial.html).

## Data sets

Examples given here make use of `dat30` data set distributed with `solarius` package. These are simulated data, and this data set was originally created in `multic` package and stored there in files. The version `dat30` of the data set is a subset for `famid < 30`, and it is stired in `*.RData` file.

`dat30` data set is lazy loaded. Hence, the user just needs to load the package:

```
library(solarius)
```
