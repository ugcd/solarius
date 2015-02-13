#' Function solarMultipoint.
#'
#' @export
solarMultipoint <- function(formula, data, dir,
  kinship,
  traits, covlist = "1",
  # input data to multipoint 
  mibddir,
  chr, interval, 
  multipoint.options = "", multipoint.settings = "",
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
  
  # `chr`
  if(missing(chr)) {
    chr <- "all"
  }
  chr.str <- paste(chr, collapse = ",")
  
  # `interval`
  if(missing(interval)) {
    interval <- 1
  }

  
  # cores
  if(is.null(cores)) {  
    cores <- 1
  }
  
  is.tmpdir <- missing(dir)
  
  ### step 2: SOLAR dir
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarMultipoint-")
  }
  if(verbose > 1) cat(" * solarMultipoint: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` used\n")

  ### step 3: compute a polygenic model by calling `solarPolygenic`
  tsolarMultipoint$polygenic <- proc.time()
  out <- solarPolygenic(formula, data, dir,
    kinship, traits, covlist, ..., verbose = verbose)

  # make a copy of `dir`
  files.dir <- list.files(dir, include.dirs = TRUE, full.names = TRUE)
  dir.poly <- file.path(dir, "solarPolygenic")
  stopifnot(dir.create(dir.poly, showWarnings = FALSE, recursive = TRUE))
  stopifnot(file.copy(from = files.dir, to = dir.poly, recursive = TRUE))
  
  ### step 4: add multipoint-specific slots to `out`
  tsolarMultipoint$premultipoint <- proc.time()
  
  out$multipoint <- list(call = mc,
    cores = cores,
    # input/output files
    dir.poly = dir.poly,
    out.dirs = "multipoint", out.chr = chr.str,
    # input/output data for multipoint
    mibddir = mibddir, chr = chr, chr.str = chr.str, interval = interval,
    multipoint.options = multipoint.options, multipoint.settings = multipoint.settings,
    tprofile = list(tproc = list()))

 ### step 5: prepare data for parallel computation (if necessary)
  out <- prepare_multipoint_files(out, dir)
  
  ### step 6: run multipoint
  tsolarMultipoint$runmultipoint <- proc.time()
  out <- run_multipoint(out, dir)
  
  ### clean 
  unlink(dir.poly, recursive = TRUE)
  
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

prepare_multipoint_files <- function(out, dir)
{  
  stopifnot(!is.null(out$multipoint$cores))
  stopifnot(!is.null(out$multipoint$out.dirs))
  stopifnot(!is.null(out$multipoint$out.chr))

  cores <- out$multipoint$cores
  out.dirs0 <- out$multipoint$out.dirs
  out.chr0 <- out$multipoint$out.chr
  chr <- out$multipoint$chr
  
  if(cores == 1) {
    out.dirs <- out.dirs0
    out.chr <- out.chr0
  } else {
    out.dirs <- paste(out.dirs0, 1:length(chr))
    out.chr <- chr
  }

  out$multipoint$out.dirs <- out.dirs
  out$multipoint$out.chr <- out.chr
  
  return(out)
}


run_multipoint <- function(out, dir)
{ 
  trun_multipoint <- list()
  trun_multipoint$args <- proc.time()
  
  cores <- out$multipoint$cores
  
  out.dirs <- out$multipoint$out.dirs
  out.chr <- out$multipoint$out.chr  
  
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

  if(cores == 1) {
    out.gr <- llply(1, function(i) {
      solar_multipoint(dir, out, out.dirs, out.chr)
    })
  } else {
    num.out.dirs <- length(out.dirs)
    out.gr <- llply(1:num.out.dirs, function(i) {
      if(out$verbose) cat(" * solarMultipoint: ", i, "/", num.out.dirs, "batches...\n")
      solar_multipoint(dir, out, out.dirs[i], out.chr[i])
    }, .parallel = parallel)
  }
      
  ### process results
  trun_multipoint$results <- proc.time()
  results.list <- llply(out.gr, function(x) try({
    try(read_multipoint_lod(x$tab.dir, num.traits = length(out$traits)))
    #pedlod <- try(read_multipoint_pedlod(dir.multipoint))
  }))
  
  # -- try to union `lodf`
  num.passes <- results.list[[1]]$num.passes
  
  lodf <- results.list 
  ret <- try({
    ldply(lodf, function(x) x$df)
  })

  if(class(ret)[1] != "try-error") {
    lodf <- ret
  }
    
  # -- extract multipoint. solar outputs
  multipoint.solar <- llply(out.gr, function(x) x$solar)

  out.multipoint.solar <- list(cmd = llply(multipoint.solar, function(x) x$cmd), 
      solar.ok = llply(multipoint.solar, function(x) x$solar.ok))
    
  # -- final output
  out.multipoint <- list(num.passes = num.passes, lodf = lodf, solar = out.multipoint.solar)

  ### assign
  out$lodf <- out.multipoint$lodf
  out$multipoint$num.passes <- out.multipoint$num.passes
  out$multipoint$solar <- out.multipoint$solar
  
  ### return
  trun_multipoint$return <- proc.time()
  out$multipoint$tprofile$tproc$trun_multipoint <- trun_multipoint
      
  return(out)
}
