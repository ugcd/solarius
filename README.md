## solarius

[![cran version](http://www.r-pkg.org/badges/version/solarius)](https://cran.r-project.org/web/packages/solarius)
[![downloads](http://cranlogs.r-pkg.org/badges/solarius)](http://cranlogs.r-pkg.org/badges/solarius)
[![total downloads](http://cranlogs.r-pkg.org/badges/grand-total/solarius)](http://cranlogs.r-pkg.org/badges/grand-total/solarius)
[![research software impact](http://depsy.org/api/package/cran/solarius/badge.svg)](http://depsy.org/package/r/solarius)


_Note_: Manuscript of the package is published in [Bioinformatics](http://bioinformatics.oxfordjournals.org/content/early/2016/03/09/bioinformatics.btw080). 
Preprint is available on [biorxiv]((http://biorxiv.org/content/early/2015/12/25/035378).

`solarius` is an R package, wrapper to SOLAR.

* Package on [CRAN](https://cran.r-project.org/package=solarius)
* Documentation [http://ugcd.github.io/solarius/doc/](http://ugcd.github.io/solarius/doc/)
* Vignettes 
  * R code [vignettes/](vignettes/)
  * hmlt output:
     1. [tutorial.html](http://ugcd.github.io/solarius/vignettes/tutorial.html)
     2. [minimal.html](http://ugcd.github.io/solarius/vignettes/minimal.html)
     3. [modelsGAIT1.html](http://ugcd.github.io/solarius/vignettes/modelsGAIT1.html)
* Project web [http://ugcd.github.io/solarius/](http://ugcd.github.io/solarius/) (under construction)     


### Install package

Install the official release from [CRAN](https://cran.r-project.org/package=solarius):

```
install.packages("solarius")
```

Install the latest development version from source on GitHub (master branch): 

```
library(devtools)
install_github("ugcd/solarius")
```

_Note_: Starting from version 3.*, `solarius` is not supported for Windows. [DESCRIPTION](https://github.com/ugcd/solarius/blob/master/DESCRIPTION) file has a line `OS_type: unix`.
This is a limitation of the `solarius` package that comes from the dependency on SOLAR.
See more details on the web page of SOLAR [for Windows](http://solar.txbiomedgenetics.org/solarwindows.html).

More information about the installation process of both, SOLAR and solarius, is given in the correspondent [section](http://ugcd.github.io/solarius/vignettes/tutorial.html#installation) of the tutorial vignette.

## References

* [Appendix 1. SOLAR Command Descriptions](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html)
* [SOLAR web page at txbiomedgenetics.org](http://solar.txbiomedgenetics.org/)
* [SOLAR Eclipse is a new collaboration to develop genetic analysis tools for imaging applications](http://www.nitrc.org/projects/se_linux/)

## Motivation

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

 
### On the SOLAR side

* Designed for the family-based studies (HHID, PROBND, FAMID)
  * support for extended pedigrees
* Optimization routines for computing VC
* Advanced polygenic models
  * support for multivariate models
  * liability threshold model
  * LRT applied to both covariates and variance components
* Elaborated linkage models
  * Multi-pass
  * Multivariate
  * Adjustment of LOD scores
* Association models
  * Speed-up with residuals
* Advanced VC models
  * Sex-specificity (custom scripts)
  * Longitudinal (custom scripts)

### On the R side

* Interactive environment for data manipulation
* Graphics
  * Plot residuals, QQ-plot, Manhattan plot
* Parallel computing


## Quick start

```
# load library
library(solarius)

# load data set for running polygenic and linkage models
data(dat30)

# univariate polygenic model
mod1 <- solarPolygenic(trait1 ~ age + sex, dat30, covtest = TRUE)
 
# bivariate polygenic model
mod2 <- solarPolygenic(trait1 + trait2 ~ 1, dat30,
  polygenic.options = '-testrhoe -testrhog')

# specify directory with IBD matrices and run linkage model
mibddir <- system.file('extdata', 'solarOutput',
  'solarMibdsCsv', package = 'solarius') 
link <- solarMultipoint(trait1 ~ 1, dat30,
  mibddir = mibddir, chr = 5)

# load data set and run association model in parallel
data(dat50)
assoc <- solarAssoc(trait ~ age + sex, phenodata,
  kinship = kin, snpdata = genodata, cores = 2)
```  
