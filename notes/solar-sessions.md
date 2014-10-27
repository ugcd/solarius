## mgassoc

References

* SOLAR man [page](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html#mgassoc)

Example for `SLBDF` dataset in R package `salamboR`:

Step 1: export data to a directory (e.g. `solar`) in SOLAR format.

```
library(salamboR)
data(SLBDF, package="salamboR")
geneSet2solar(SLBDF, "solar")
```

First lines of `solar.gen` file:

```
ID,gen1,gen2,gen3
51101,,,
51102,,,
51202,2/2,1/1,1/1
51203,1/1,1/1,1/2
51204,1/1,2/1,1/1
```

Step 2: go to that directory and run SOLAR.

```
snp load solar.gen
snp covar -nohaplos
trait phen1
mgassoc -files snp.genocov
```

Output of the last command looks like:

```
solar> mgassoc -files snp.genocov                                              
    ** Output file is now phen1/mgassoc.out
    ** Evaluating SNPs found in snp.genocov...
   maximizing null for gen1...
Defaulting to polygenic model type
   maximizing null for gen1...
   Sample Size: 72.  Loglikelihood: -85.159484  SD: 2.083804722508284
 
SNP,NAv,chi,p(SNP),bSNP,bSNPse,Varexp
gen1,72,0.191784,0.661436,-0.219038,0.000000,0.002776
   maximizing null for gen2...
   Sample Size: 73.  Loglikelihood: -86.235190  SD: 2.079076230157286
gen2,73,0.163340,0.686100,-0.184035,0.000000,0.002333
   maximizing null for gen3...
   Sample Size: 72.  Loglikelihood: -84.781231  SD: 2.072412728136059
gen3,72,4.791518,0.028600,0.906323,0.000000,0.067086                           

    ** results written to phen1/mgassoc.out
```

