data(dat50)

mod1 <- solarAssoc(traits = "trait", data = phenodata, snpdata = genodata)
mod2 <- solarAssoc(traits = "trait", data = phenodata, snpdata = genodata,
  kinship = kin)

head(sort(mod1$snpf$pSNP))
head(sort(mod2$snpf$pSNP))

