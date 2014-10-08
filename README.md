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

1. `df2solar` function, which export both pedigree and phenotype data into a folder of `SOLAR` format
2. simple polygenic model (univariate, bivariate, etc); see `solarPolygenic` function

### TODO

Polygenic model:

* add house-hold effect
* add option of trait-specific covariates
* add data frames with h2r, p-values, etc

Association model:

* think of which formats to support except the `SOLAR` one
* parallelize calculations
* check out if `SOLAR` supports dosage format

Linkage model:

* make use of all linkage options availabe in `SOLAR`: second-path, adjustment of inflated scores
* parallel computations
