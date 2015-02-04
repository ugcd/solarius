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
