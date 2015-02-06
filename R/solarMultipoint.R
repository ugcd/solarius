#' Function solarMultipoint.
#'
#' @export
solarMultipoint <- function(formula, data, dir,
  kinship,
  traits, covlist = "1",
  # input data to multipoint 
  mibddir,
  # output data from multipoint
  # misc
  cores = getOption("cores"),
  ...,
  verbose = 0) 
{
  tsolarMultipoint <- list()
  tsolarMultipoint$args <- proc.time()
  
  ### step 1: process par & create `out`
  mc <- match.call()
  
  # missing parameters
  stopifnot(!missing(mibddir))
  stopifnot(file.exists(mibddir))
  mibddir <- normalizePath(mibddir)
  
  # cores
  if(is.null(cores)) {  
    cores <- 1
  }
  
  is.tmpdir <- missing(dir)
  is.dir.poly <- (cores < 1)
  
  ### step 2: SOLAR dir
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarMultipoint-")
  }
  if(verbose) cat(" * solarMultipoint: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` used\n")

  ### step 3: compute a polygenic model by calling `solarPolygenic`
  tsolarMultipoint$polygenic <- proc.time()
  out <- solarPolygenic(formula, data, dir,
    kinship, traits, covlist, ..., verbose = verbose)

  # make a copy of `dir`
  if(is.dir.poly) {
    files.dir <- list.files(dir, include.dirs = TRUE, full.names = TRUE)
    dir.poly <- file.path(dir, "solarPolygenic")
    stopifnot(dir.create(dir.poly, showWarnings = FALSE, recursive = TRUE))
    stopifnot(file.copy(from = files.dir, to = dir.poly, recursive = TRUE))
  }
  
  ### step 4: add multipoint-specific slots to `out`
  tsolarMultipoint$premultipoint <- proc.time()
  
  out$multipoint <- list(call = mc,
    cores = cores,
    # input/output data for multipoint
    mibddir = mibddir,
    tprofile = list(tproc = list()))

  ### step 5: run multipoint
  tsolarMultipoint$runmultipoint <- proc.time()
  #out <- run_multipoint(out, dir)
  
  ###
  ###
  ### prepare `cmd`  
  dir.multipoint <- dir
  
  trait.dir <- paste(out$traits, collapse = ".")
  trait.path <- file.path(dir, trait.dir)
  model.path <- file.path(trait.dir, out$solar$model.filename)
  
  cmd <- c(paste("load model", model.path),
    paste("mibddir", out$multipoint$mibddir), 
    "chromosome all", "interval 1", 
    "multipoint -overwrite")
  
  ret <- solar(cmd, dir.multipoint, result = FALSE) 

  results <- try(read_multipoint_lod(trait.path, num.traits = length(out$traits)))
  #pedlod <- try(read_multipoint_pedlod(dir.multipoint))

  out$multipoint <- c(out$multipoint, results)#, pedlod)  
  ###
  ###
  out$multipoint$solar$cmd <- cmd 

  ### clean 
  if(is.dir.poly) {
    unlink(dir.poly, recursive = TRUE)
  }
  
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
    if(verbose > 1) cat("  -- solarMultipoint: temporary directory `", dir, "` unlinked\n")
  }

  ### return
  tsolarMultipoint$return <- proc.time()
  out$multipoint$tprofile$tproc$tsolarMultipoint <- tsolarMultipoint

  out$multipoint$tprofile <- try({
    procc_tprofile(out$multipoint$tprofile)
  }, silent = TRUE)
  
  oldClass(out) <- c("solarMultipoint", oldClass(out))
  return(out)
}

solar_multipoint <- function(dir, out)
{
  ### check arguments
  stopifnot(file.exists(dir))
  
  ### prepare `cmd`  
  dir.multipoint <- dir
  
  trait.dir <- paste(out$traits, collapse = ".")
  model.path <- file.path(trait.dir, out$solar$model.filename)
  
  cmd <- c(paste("load model", model.path),
    paste("mibddir", out$multipoint$mibddir), 
    "chromosome all", "interval 1", 
    "multipoint -overwrite")
  
  ret <- solar(cmd, dir.multipoint, result = FALSE) 


  ### run solar    
  ret <- solar(cmd, dir.assoc, result = FALSE) 
  # `result = FALSE`, because all assoc. results are printed to output
  
  solar.ok <- file.exists(tab.file)
    
  ### return  
  out <-  list(solar = list(cmd = cmd, solar.ok = solar.ok), tab.file = tab.file)

  return(out)
}

run_multipoint <- function(out, dir)
{ 
  trun_multipoint <- list()
  trun_multipoint$args <- proc.time()
  
  cores <- out$assoc$cores
    
  ### run
  trun_multipoint$solar <- proc.time()
  parallel <- (cores > 1)
  if(parallel) {
    ret <- require(doMC)
    if(!ret) {
      stop("`doMC` package is required for parallel calculations")
    }
    doMC::registerDoMC(cores)
  }

  ### case 1
  if(length(genocov.files) > 1) {
    out.gr <- llply(1:length(genocov.files), function(i) {
      solar_assoc(dir, out, genocov.files[i], snplists.files[i], out.dirs[i], out.files[i])
    }, .parallel = parallel)
  ### case 2 (length(genocov.files) == 1)
  } else if(cores == 1) {
    out.gr <- llply(1, function(i) {
      solar_assoc(dir, out, genocov.files, snplists.files, out.dirs, out.files)
    })
  ### case 2 (length(genocov.files) == 2)
  } else {
    out.gr <- llply(1:length(snplists.files), function(i) {
      solar_assoc(dir, out, genocov.files, snplists.files[i], out.dirs[i], out.files[i])
    }, .parallel = TRUE)
  }
      
  ### process results
  trun_multipoint$results <- proc.time()
  snpf.list <- llply(out.gr, function(x) try({
    fread(x$tab.file)}), .parallel = parallel)
  
  # -- try to union `snpf` slots in `snpf.list`
  snpf <- snpf.list 
  ret <- try({
    rbindlist(snpf)
  })

  if(class(ret)[1] != "try-error") {
    snpf <- ret
    snpf <- rename(snpf, c("p(SNP)" = "pSNP"))
  }
    
  # -- extract assoc. solar outputs
  assoc.solar <- llply(out.gr, function(x) x$solar)
    out.assoc.solar <- list(cmd = llply(assoc.solar, function(x) x$cmd), 
      solar.ok = llply(assoc.solar, function(x) x$solar.ok))
    
  # -- final output
  out.assoc <- list(snpf = snpf, solar = out.assoc.solar)

  ### assign
  out$snpf <- out.assoc$snpf
  out$assoc$solar <- out.assoc$solar
  
  ### return
  trun_multipoint$return <- proc.time()
  out$assoc$tprofile$tproc$trun_multipoint <- trun_multipoint
      
  return(out)
}
