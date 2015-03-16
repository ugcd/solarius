## solarius

R package wrapper to SOLAR

* Project web [http://ugcd.github.io/solarius/](http://ugcd.github.io/solarius/).
* Vignettes 
  * R code [vignettes/](vignettes/)
  * hmlt output:
     1. [modelsGAIT1.html](http://ugcd.github.io/solarius/vignettes/modelsGAIT1.html)
     2. [models.html](http://ugcd.github.io/solarius/vignettes/models.html)

The X-files

* http://ugcd.github.io/solarius/projects/02-compare-tools/01-solar-lme4.html

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
