
#----------------------------------
# Association functions
#----------------------------------
solar_assoc <- function(dir, out, snplist.file, out.dir, out.file)
{
  stopifnot(file.exists(dir))
  
  ### make `cmd`
  trait.dir <- paste(out$traits, collapse = ".")
  model.path <- file.path(trait.dir, out$solar$model.filename)
  cmd <- c(
    # needed to reload phenotypes, in order to avoid errors like 
    # `Phenotype named snp_s1 found in several files`
    #  - diagnostic: go to SOLAR dir and show phenos by `pheno` command,
    #    and you will see `snp.genocov` duplicated
    "load pheno dat.phe", 
    paste("load model", model.path),
    paste("outdir", out.dir),
    # mga option `-files snp.genocov` is not passed, as that provokes pheno-dulicates 
    # (SOLAR's strange things)
    paste("mga ", "-files snp.genocov ", "-snplists ", snplist.file, " -out ", out.file, sep = ""))
    
  ### run solar    
  ret <- solar(cmd, dir, result = FALSE) 
  # `result = FALSE`, because all assoc. results are printed to output

  tab.file <- file.path(dir, out.dir, out.file)
  solar.ok <- file.exists(tab.file)
  
  ### read results
  snpf <- data.frame()
  ret <- try({
    read.table(tab.file, header = TRUE, sep = ",")
  })

  if(class(ret) != "try-error") {
    snpf <- ret
    snpf <- rename(snpf, c("p.SNP." = "pSNP"))
  }
  
  ### return  
  out <-  list(solar = list(cmd = cmd, solar.ok = solar.ok), snpf = snpf)

  return(out)
}
