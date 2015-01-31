
#----------------------------------
# Association functions
#----------------------------------

# function parameters
# - snplists.files
# - out.dir
# - out.file
#
# slots in the object `out` required to run SOLAR> mga
# - out$traits
# - out$solar$model.filename
# - out$solar$phe.filename)
solar_assoc <- function(dir, out, genocov.files, snplists.files, out.dir, out.file)
{
  ### check arguments
  stopifnot(file.exists(dir))
  
  ### var
  dir.poly <- out$assoc$dir.poly
  out.path <- file.path(dir, out.dir)

  snplists.files.local <- out$assoc$snplists.files.local
  genocov.files.local <- out$assoc$genocov.files.local
  
  if(snplists.files.local) {
    snplists.files <- file.path(dir, snplists.files)
  }
  if(genocov.files.local) {
    genocov.files <- file.path(dir, genocov.files)
  }

  ### check files exist  
  stopifnot(all(file.exists(genocov.files)))
  stopifnot(all(file.exists(snplists.files)))
  stopifnot(dir.create(out.path))

  ### normalize path
  genocov.files <- normalizePath(genocov.files)
  snplists.files <- normalizePath(snplists.files)
  out.path <- normalizePath(out.path)
  
  ### create a temp. dir.
  dir.assoc <- file.path(dir, paste0("solar_assoc_", basename(out.file)))
  stopifnot(dir.create(dir.assoc))
  files.dir <- list.files(dir.poly, include.dirs = TRUE, full.names = TRUE)
  stopifnot(file.copy(from = files.dir, to = dir.assoc, recursive = TRUE))
      
  ### make `cmd`
  # local variables
  trait.dir <- paste(out$traits, collapse = ".")
  model.path <- file.path(trait.dir, out$solar$model.filename)
  
  # combine variables into a command string `cmd`
  cmd <- c(
    # needed to reload phenotypes, in order to avoid errors like 
    # `Phenotype named snp_s1 found in several files`
    #  - diagnostic: go to SOLAR dir and show phenos by `pheno` command,
    #    and you will see `snp.genocov` duplicated
    paste("load pheno", out$solar$phe.filename), 
    paste("load model", model.path),
    paste("outdir", out.path),
    # mga option `-files snp.genocov` is not passed, as that provokes pheno-dulicates 
    # (SOLAR's strange things)
    paste("mga ", "-files ", paste(genocov.files, collapse = " "), 
      " -snplists ", paste(snplists.files, collapse = " "), " -out ", out.file, sep = ""))
  
  ### run solar    
  ret <- solar(cmd, dir.assoc, result = FALSE) 
  # `result = FALSE`, because all assoc. results are printed to output

  tab.file <- file.path(out.path, out.file)
  solar.ok <- file.exists(tab.file)

  ### clean
  unlink(dir.assoc, recursive = TRUE)
    
  ### return  
  out <-  list(solar = list(cmd = cmd, solar.ok = solar.ok), tab.file = tab.file)

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
