## solarius

R package wrapper to SOLAR

References:

* [Appendix 1. SOLAR Command Descriptions](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html)

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

Done:

1. `df2solar` function, which export both pedigree and phenotype data into a folder of `SOLAR` format
2. simple polygenic model (univariate, bivariate, etc); see `solarPolygenic` function

### TODO

Polygenic model:

* add house-hold effect (start with `df2solar` function)
* add option of trait-specific covariates
* add a slot with Log-likelihoods (see `polygenic.logs.out` file of a model)
* track `PROBND`, `MZTWIN`, `HHID` info; see `polygenic.lib.R` in `salamboR` package
* extract residuals and make plots for them

Association model:

* think of which formats to support except the `SOLAR` one
* parallelize calculations
* check out if `SOLAR` supports dosage format

Linkage model:

* make use of all linkage options availabe in `SOLAR`: second-path, adjustment of inflated scores
* parallel computations


### Content of Software Manual

* Polygenic model (univariate)
  * `SOLAR` way to introduce covariates [link](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html#covariate), e.g. `age#sex = age + sex + age*sex` and `age*sex = age*sex`
  * difference between `*.mod` files
  * house-hold effect
* Polygenic model (bivariate)
  * trait-specific covariates
* Association model
* Linkage model

## Examples 

Examples given here make use of `dat30` data set distributed with `solarius` package. These are simulated data, and this data set was originally created in `multic` package and stored there in files. The version `dat30` of the data set is a subset for `famid < 30`, and it is stired in `*.RData` file.

`dat30` data set is lazy loaded. Hence, the user just needs to load the package:

```
library(solarius)
```

### Univariate Model

```
> solarPolygenic(trait1 ~ age + sex, dat30, covtest = TRUE)

Call: solarPolygenic(formula = trait1 ~ age + sex, data = dat30, covtest = TRUE)

File polygenic.out:
	Pedigree:    dat.ped 
	Phenotypes:  dat.phe 
	Trait:       trait1                Individuals:  174 
 
			 H2r is 0.8061621  p = 6.1167535e-10  (Significant) 
	       H2r Std. Error:  0.1100465 
 
                                      age  p = 0.9753082  (Not Sig., but fixed) 
                                      sex  p = 0.1455341  (Not Sig., but fixed) 
 
	Proportion of Variance Due to All Final Covariates Is 
				  0.0330070 
 
	Loglikelihoods and chi's are in trait1/polygenic.logs.out 
	Best model is named poly and null0 
	Final models are named poly, spor, nocovar 
	Initial sporadic and polygenic models are s0 and p0 
	Constrained covariate models are named no<covariate name> 
 
	Residual Kurtosis is -0.3603, within normal range 

 Covariates Table:
  covariate      Estimate         SE    Chi      pval
1       age  0.0004591117 0.01483782 0.0010 0.9753082
2       sex -0.4559509166 0.31250456 2.1184 0.1455341

 Variance Components Table:
  varcomp       Var        SE         pval
1     h2r 0.8061621 0.1100465 6.116753e-10
2      e2 0.1938379 0.1100465           NA
```

### Bivariate model


```
> solarPolygenic(trait1 + trait2 ~ sex, dat30)

Call: solarPolygenic(formula = trait1 + trait2 ~ sex, data = dat30)

File polygenic.out:
	Pedigree:    dat.ped 
	Phenotypes:  dat.phe 
	Trait:       trait1 trait2         Individuals:  174 
 
			 H2r(trait1) is 0.7953058   
	       H2r(trait1) Std. Error:  0.1125756 
 
			 H2r(trait2) is 0.6074364   
	       H2r(trait2) Std. Error:  0.1214936 
 
			 RhoE is 0.4524437   
	       RhoE Std. Error:  0.1797011 
 
			 RhoG is 0.9691782 
	       RhoG Std. Error:  0.0401070 
 
	       Derived Estimate of RhoP is 0.8018840 
 
 
	Loglikelihoods and chi's are in trait1.trait2/polygenic.logs.out 
	Best model is named poly and null0 
	Final models are named poly, spor 

 Covariates Table:
  covariate
1       sex

 Variance Components Table:
      varcomp  Estimate
1 h2r(trait1) 0.7953058
2  e2(trait1) 0.2046942
3 h2r(trait2) 0.6074364
4  e2(trait2) 0.3925636
5        rhog 0.9691782
6        rhoe 0.4524437
```
