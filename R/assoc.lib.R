
#----------------------------------
# Association functions
#----------------------------------
solar_assoc <- function(dir, out, snplist.file, out.dir, out.file)
{
  stopifnot(file.exists(dir))
  
  ### make `cmd`
  trait.dir <- paste(out$traits, collapse = ".")
  model.path <- file.path(trait.dir, out$solar$model.filename)
  cmd <- c(paste("load model", model.path),
    paste("outdir", out.dir),
    paste("mga -files snp.genocov ", "-snplists ", snplist.file, 
      " -out ", out.file, sep = ""))
    
  ### run solar    
  ret <- solar(cmd, dir, result = FALSE) 
  # `result = FALSE`, because all assoc. results are printed to output

  ### read results
  snpf <- data.frame()
  ret <- try({
    read.table(file.path(dir, out.dir, out.file), header = TRUE, sep = ",")
  })

  if(class(ret) != "try-error") {
    snpf <- ret
    snpf <- rename(snpf, c("p.SNP." = "pSNP"))
  }
  
  out <-  list(solar = list(cmd = cmd), snpf = snpf)
  out$solar$assoc <- list(cmd = cmd)

  return(out)
}
