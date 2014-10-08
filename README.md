## solarius

R package wrapper to SOLAR

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

### Current status

Done:

1. `df2solar` function
2. simple polygenic model (univariate, bivariate, etc); see `solarPolygenic` function

### TODO

Polygenic model:

* add house-hold effect
* add option of trait-specific covariates
* add data frames with h2r, p-values, etc


