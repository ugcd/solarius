---
layout: tutorial
title: Association model
title_id: assoc
---



  



~~~ r
args(solarAssoc)
~~~



~~~
## function (formula, data, dir, kinship, traits, covlist = "1", 
##     snpdata, snpformat = "012", cores = 1, ..., verbose = 0) 
## NULL
~~~

| snpformat |  snpdata        | dat.gen        | genocov          |
|-----------|-----------------|----------------|------------------|
| "/"       | {A/A, A/T, T/T} | as is snpdata  | {0, 1, 2}        |
| "012"     | {0, 1, 2}       | {1/1, 1/2, 2/2}| {0, 1, 2}        |
| "0.1"     | [0; 2]          | skipped        | as is in snpdata |
{: class="table"}


### `SOLAR` commands and files


Association analysis provided by `solarius` package via `solarAssoc` function
is based on `mga` command of `SOLAR`.
The following code shows an exact rules (selected in `solarius`) 
to conduct an association analysis on 2 cores in parallel.

    > mod <- solarAssoc(trait ~ 1, phenodata, snpdata = genodata, kinship = kin, cores = 2)
    > mod$solar$assoc$cmd
    [[1]]
    [1] "load pheno dat.phe"                                             
    [2] "load model trait/null0.mod"                                     
    [3] "outdir assoc1"                                                  
    [4] "mga -files snp.genocov -snplists snp.geno-list1 -out assoc.out1"
    
    [[2]]
    [1] "load pheno dat.phe"                                             
    [2] "load model trait/null0.mod"                                     
    [3] "outdir assoc2"                                                  
    [4] "mga -files snp.genocov -snplists snp.geno-list2 -out assoc.out2"


A list of specific `SOLAR` files are used in the calculations,
as described in the following table.

| `SOLAR` file | `solarAssoc` argument | Comments | 
|--------------|-----------------------|----------|
| genocov.files | Yes (alternative to `snpdata`) | Data files with genotype-covariates (e.g. file per chromosome) |
| genolist.file | No | Meta file with SNP names (internal file derived from genocov.files) |
| snplist.files | Yes (alternative to `snplist`) | Meta files with SNP names to analize |
| out.dirs | No | Output directories for association models like `mga.mod` (directory per core) |
| out.files | No | Output files to store association results (file per core) | 
{: class="table"}

Two files `genocov.files` and `genolist.file` are output files
of a group of commands, that convert genotypes to covariates.
These three commands are `snp load dat.snp`, `snp covar -nohaplos`, `snp unload`.
See `snpdata2solar` function for more details.

Other three files `snplist.file`, `out.dirs` and `out.files` 
are custom files by `solarius` package 
to control association analysis (list of snps to be analyzed, parallel computation).

| `SOLAR` file | Default value | `core == 2` | 
|--|--|
| genocov.files | `"snp.genocov"` | |
| genolist.file | `"snp.geno-list"` | |
| snplist.file | `"snp.geno-list"` | `"snp.geno-list1"`, `"snp.geno-list2"`|
| out.dirs | `"assoc"` | `"assoc1"`, `"assoc2"`|
| out.files | `"assoc.out"` | `"assoc.out1"`, `"assoc.out2"`|
{: class="table"}


### Example of association model


~~~ r
data(dat50)

mod <- solarAssoc(trait ~ 1, phenodata, snpdata = genodata, kinship = kin)
head(mod$snpf)
~~~



~~~
##   SNP NAv      chi     pSNP      bSNP bSNPse   Varexp
## 1  s1  66 0.166224 0.683490  0.144854      0 0.001258
## 2  s2  66 0.851450 0.356142 -0.665254      0 0.080241
## 3  s3  66 0.839794 0.359456 -0.330617      0 0.000000
## 4  s4  66 0.182198 0.669491  0.073773      0 0.000000
## 5  s5  66 0.049818 0.823380  0.344516      0 0.007852
## 6  s6  66 2.882008 0.089574 -0.249210      0 0.051719
~~~

