
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
    paste("load pheno", out$solar$phe.filename), 
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

#----------------------------------
# Support functions
#----------------------------------

guess_snpformat <- function(snpdata, snpfile.gen, snpfile.genocov)
{
  if(!missing(snpdata)) {
    # first row
    vals <- snpdata[1, ]
    vals.class <- class(vals)
  } else {
    stop("error in `guess_snpformat`: snp values not extracted.")
  }
    
  # - option 1: `/` format
  if(vals.class == "character") {
    format.ok <- all(grepl("\\/", vals))
    if(!format.ok) {
      stop("error in `guess_snpformat`: snp data (1st row) is character, but not in supported `/` format.")
    } else {
      return("/")
    }
  } else if(vals.class == "numeric") {
    # - option 2: `012` format
    format.ok <- all(vals %in% c(0, 1, 2))
    if(format.ok) {
      return("012")
    } 
    else {
      # - option 3: `0.1` format
      return("0.1")
    }
  }
}
