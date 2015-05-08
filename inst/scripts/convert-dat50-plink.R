# @ http://www.gwaspi.org/?page_id=145

### par
file.ped <- "dat50.ped"
file.map <- "dat50.map"

### data
data(dat50)

#> str(phenodata)
#'data.frame':	66 obs. of  4 variables:
# $ id   : num  1 2 3 4 5 6 7 8 9 10 ...
# $ sex  : int  0 1 0 0 0 1 0 1 1 0 ...
# $ age  : int  80 77 56 44 75 79 75 82 77 76 ...
# $ trait: num  -1.763 -1.423 -0.805 0.268 -1.334 ...

#> str(snpdata)
#'data.frame':	50 obs. of  4 variables:
# $ name    : chr  "s1" "s2" "s3" "s4" ...
# $ chrom   : int  1 1 1 1 1 1 1 1 1 1 ...
# $ position: num  2105324 2105467 2106094 2108138 2109262 ...
# $ gene    : chr  "gene1" "gene1" "gene1" "gene1" ...

### write ped files
pdat <- data.frame(FAMID = 0, ID = phenodata$id, PA = 0, MO = 0,
  SEX = phenodata$sex, # Sex (1=male; 2=female; other=unknown)
  aff = 0) # Affection (0=unknown; 1=unaffected; 2=affected))


gdat <- matrix(character(), nrow = nrow(genodata), ncol = 2 * ncol(genodata) + 1)
for(i in 1:ncol(genodata)) {
  ind <- seq(2 * i, by = 1, length = 2) - 1
  gdat[, ind] <- laply(strsplit(genodata[, i], "/"), function(x) x)  
}

gdat[, ncol(gdat)] <- rownames(genodata) # IDs
colnames(gdat) <- c(unlist(llply(colnames(genodata), function(x) paste0(x, "_A", 1:2))), "ID")
gdat <- as.data.frame(gdat, stringsAsFactors = FALSE)

dat <- merge(pdat, gdat, by = "ID")
#> colnames(dat)
#  [1] "ID"     "FAMID"  "PA"     "MO"     "SEX"    "aff"    "s1_A1"  "s1_A2" 
#  [9] "s2_A1"  "s2_A2"  "s3_A1"  "s3_A2"  "s4_A1"  "s4_A2"  "s5_A1"  "s5_A2" 
# ...
#  [105] "s50_A1" "s50_A2"

write.table(dat, file.ped,
  row.names = FALSE, col.names = FALSE,
  sep = " ", quote = FALSE, na = "")

### write 
mdat <- data.frame(chr = snpdata$chrom, SNP = snpdata$name, cM = 0, bp = snpdata$position)

write.table(mdat, file.map,
  row.names = FALSE, col.names = FALSE,
  sep = " ", quote = FALSE, na = "")
  
### run plink
ret <- system("plink --noweb --file dat50", intern = TRUE)  

