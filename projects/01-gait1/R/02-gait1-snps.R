### inc
library(plyr)
### par
dir <- "/home/datasets/GAIT1/GWAS/SFBR/Impute"

### list dir. like `c4.12001.12500`
stopifnot(file.exists(dir))
dirs <- list.dirs(dir, full.names = FALSE, recursive = FALSE)

dirs <- grep("^c[1-9]\\.*",dirs, value = TRUE)
stopifnot(length(dirs) > 0)

### extract infro. from `dirs`
out <- strsplit(dirs, "\\.")

num.snps <- laply(dirs, function(x)
  length(readLines(file.path(dir, x, "snp.geno-list"))))

### tab
tab <- data.frame(dir = dirs,
  chr = as.integer(laply(out, function(x) gsub("c", "", x[1]))),
  start = as.integer(laply(out, function(x) x[2])),
  end = as.integer(laply(out, function(x) x[3])),
  num.snps = num.snps)

# order
ord <- with(tab, order(chr, start))
tab <- tab[ord, ]  

### print
print(head(tab))
