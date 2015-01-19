#' Function solarAssoc.
#'
#' @export
solarAssoc <- function(formula, data, dir,
  kinship,
  traits, covlist = "1",
  # association 
  snpformat, snpdata, snpcovdata, snplist, genocov.files, snplists.files,
  cores = getOption("cores"),
  ...,
  verbose = 0) 
{
  ### step 1: process par & create `out`
  mc <- match.call()
  
  # missing parameters
  #if(missing(snpformat)) snpformat <- "012"
  
  if(missing(snpdata) & missing(snpcovdata) & missing(genocov.files)) {
    stop("Error in `solarAssoc`: input SNP data must be given by either `snpdata`/`snpcovdata` or `genocov.files` arguments.")
  }
  if(!missing(snpdata) & !missing(snpcovdata)) {
    stop("Error in `solarAssoc`: input SNP data must be given by either `snpdata` or `snpcovdata` or `genocov.files` arguments.")
  }

  # check for matrix format  
  if(!missing(snpdata)) {
    stopifnot(class(snpdata) == "matrix")
  }
  if(!missing(snpcovdata)) {
    stopifnot(class(snpcovdata) == "matrix")
  }
    
  # cores
  if(is.null(cores)) {  
    cores <- 1
  }
  
  is.tmpdir <- missing(dir)
  
  # gues format
  #if(missing(snpformat)) {
  #  snpformat <- guess_snpformat(snpdata, snpfile.gen, snpfile.genocov)
  #}

  ### step 2: SOLAR dir
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarAssoc-")
  }
  if(verbose) cat(" * solarAssoc: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` used\n")

  ### step 3: compute a polygenic model by calling `solarPolygenic`
  out <- solarPolygenic(formula, data, dir,
    kinship, traits, covlist, ..., verbose = verbose)

  ### step 3.1: add assoc.-specific slots to `out`
  out$assoc <- list(call = mc, #snpformat = snpformat,
    cores = cores,
    genocov.files = ifelse(missing(genocov.files), "snp.genocov", genocov.files),
    genolist.file = "snp.geno-list",
    snplists.files = ifelse(missing(snplists.files), "snp.geno-list", snplists.files),
    out.dirs = "assoc", out.files = "assoc.out")

  ### step 4: add genotype data to `dir`
  #snpdata <- format_snpdata(snpdata, snpformat)
  if(!missing(snpdata)) {
    ret <- snpdata2solar(snpdata, dir)
  }

  if(!missing(snpcovdata)) {
    ret <- snpcovdata2solar(snpcovdata, out, dir)
  }
  
  ### number of snps
  snps <- readLines(file.path(dir, out$assoc$genolist.file))
  num.snps <- length(snps)

  out$assoc$num.snps <- num.snps
    
  ### step 6: prepare data for parallel computation (if necessary)
  out <- prepare_assoc_files(out, dir)

  ### step 7: run assoc  
  out <- run_assoc(out, dir)

  ### clean 
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
    if(verbose > 1) cat("  -- solarAssoc: temporary directory `", dir, "` unlinked\n")
  }

  ### return
  oldClass(out) <- c("solarAssoc", oldClass(out))
  return(out)
}

prepare_assoc_files <- function(out, dir)
{  
  stopifnot(!is.null(out$assoc$cores))
  stopifnot(!is.null(out$assoc$genocov.files))
  stopifnot(!is.null(out$assoc$genolist.file))
  stopifnot(!is.null(out$assoc$out.dirs))
  stopifnot(!is.null(out$assoc$out.files))
  
  cores <- out$assoc$cores
  genocov.files <- out$assoc$genocov.files
  genolist.file <- out$assoc$genolist.file
  snplists.files0 <- out$assoc$snplists.files
  out.dirs0 <- out$assoc$out.dirs
  out.files0 <- out$assoc$out.files

  stopifnot(length(genolist.file) == 1)
  
  if(cores == 1) {
    snplists.files <- snplists.files0
    out.dirs <- out.dirs0
    out.files <- out.files0
  } else {
    ### number of snps
    snps <- readLines(file.path(dir, genolist.file))
    num.snps <- length(snps)

    num.gr <- cores 
    gr <- cut(1:num.snps, breaks = seq(1, num.snps, length.out = num.gr + 1), include.lowest = TRUE)

    snplists.files <- rep(as.character(NA), num.gr)
    out.dirs <- rep(as.character(NA), num.gr)
    out.files <- rep(as.character(NA), num.gr)

    for(k in 1:nlevels(gr)) {
      snplists.files.k <- paste(snplists.files0, k, sep = "")
      out.dirs.k <- paste(out.dirs0, k, sep = "")
      out.files.k <- paste(out.files0, k, sep = "")
      
      gr.k <- levels(gr)[k]
      snps.k <- snps[gr %in% gr.k]
    
      writeLines(snps.k, file.path(dir, snplists.files.k))
      
      snplists.files[k] <- snplists.files.k
      out.dirs[k] <- out.dirs.k
      out.files[k] <- out.files.k
    }
  }
  stopifnot(all(!is.na(snplists.files)))
  stopifnot(all(!is.na(out.dirs)))
  stopifnot(all(!is.na(out.files)))

  out$assoc$snplists.files <- snplists.files
  out$assoc$out.dirs <- out.dirs
  out$assoc$out.files <- out.files
  
  return(out)
}

run_assoc <- function(out, dir)
{    
  cores <- out$assoc$cores
  
  snplists.files <- out$assoc$snplists.files
  out.dirs <- out$assoc$out.dirs
  out.files <- out$assoc$out.files

  ### step 5: run assoc
  if(cores == 1) {
    out.assoc <- solar_assoc(dir, out, snplists.files, out.dirs, out.files)
  } else {
    ret <- require(doMC)
    if(!ret) {
      stop("`doMC` package is required for parallel calculations")
    }
    doMC::registerDoMC(cores)
    
    out.gr <- llply(1:length(snplists.files), function(i) {
      solar_assoc(dir, out, snplists.files[i], out.dirs[i], out.files[i])
    }, .parallel = TRUE)
    
    # process results
    snpf.list <- llply(out.gr, function(x) list(snpf = x$snpf))
    
    # -- try to union `snpf` slots in `snpf.list`
    snpf <- snpf.list 
    ret <- try({
      ldply(snpf.list, function(x) x$snpf)
    })

    if(class(ret) != "try-error") {
      snpf <- ret
    }
    
    # -- extract assoc. solar outputs
    assoc.solar <- llply(out.gr, function(x) x$solar)
    out.assoc.solar <- list(cmd = llply(assoc.solar, function(x) x$cmd), 
      solar.ok = llply(assoc.solar, function(x) x$solar.ok))
    
    # -- final output
    out.assoc <- list(snpf = snpf, solar = out.assoc.solar)
  }
  out$snpf <- out.assoc$snpf
  out$assoc$solar <- out.assoc$solar
    
  return(out)
}
