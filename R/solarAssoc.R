#' Function solarAssoc.
#'
#' @export
solarAssoc <- function(formula, data, dir,
  kinship,
  traits, covlist = "1",
  # association 
  snpdata, snpformat = "012",
  cores = getOption("cores"),
  ...,
  verbose = 0) 
{
  ### step 1: process par & create `out`
  mc <- match.call()

  stopifnot(!missing(snpdata))
  stopifnot(class(snpdata) == "matrix")
  
  if(is.null(cores)) {  
    cores <- 1
  }
  
  is.tmpdir <- missing(dir)

  ### step 2: SOLAR dir
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarAssoc-")
  }
  if(verbose) cat(" * solarAssoc: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` used\n")
  
  ### step 3: compute a polygenic model by calling `solarPolygenic`
  out <- solarPolygenic(formula, data, dir,
    kinship, traits, covlist, ..., verbose = verbose)

  ### step 4: add genotype data to `dir`
  snpdata <- format_snpdata(snpdata, snpformat)
  ret <- snpdata2solar(snpdata, dir)

  ### step 6: prepare data for parallel computation (if necessary)
  genolist.file <- "snp.geno-list"

  snps <- readLines(file.path(dir, genolist.file))
  num.snps <- length(snps)

  snplist.files0 <- "snp.geno-list"
  out.dirs0 <- "assoc"
  out.files0 <- "assoc.out"

  if(cores == 1) {
    snplist.files <- snplist.files0
    out.dirs <- out.dirs0
    out.files <- out.files0
  } else {
    num.gr <- cores 
    gr <- cut(1:num.snps, breaks = seq(1, num.snps, length.out = num.gr + 1), include.lowest = TRUE)

    snplist.files <- rep(as.character(NA), num.gr)
    out.dirs <- rep(as.character(NA), num.gr)
    out.files <- rep(as.character(NA), num.gr)

    for(k in 1:nlevels(gr)) {
      snplist.files.k <- paste(snplist.files0, k, sep = "")
      out.dirs.k <- paste(out.dirs0, k, sep = "")
      out.files.k <- paste(out.files0, k, sep = "")
      
      gr.k <- levels(gr)[k]
      snps.k <- snps[gr %in% gr.k]
    
      writeLines(snps.k, file.path(dir, snplist.files.k))
      
      snplist.files[k] <- snplist.files.k
      out.dirs[k] <- out.dirs.k
      out.files[k] <- out.files.k
    }
  }
  stopifnot(all(!is.na(snplist.files)))
  stopifnot(all(!is.na(out.dirs)))
  stopifnot(all(!is.na(out.files)))
    
  ### step 5: run assoc
  if(cores == 1) {
    out.assoc <- solar_assoc(dir, out, snplist.files, out.dirs, out.files)
  } else {
    ret <- require(doMC)
    if(!ret) {
      stop("`doMC` package is required for parallel calculations")
    }
    doMC::registerDoMC(cores)
    
    out.gr <- llply(1:length(snplist.files), function(i) {
      solar_assoc(dir, out, snplist.files[i], out.dirs[i], out.files[i])
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
    out.assoc.solar <- llply(out.gr, function(x) x$solar)
    
    # -- final output
    out.assoc <- list(snpf = snpf, solar = out.assoc.solar)
  }
  out$nsnps <- num.snps
  out$snpf <- out.assoc$snpf
  out$solar$assoc <- out.assoc$solar
  
  ### clean 
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
    if(verbose > 1) cat("  -- solarAssoc: temporary directory `", dir, "` unlinked\n")
  }
  
  ### reutrn 
  out$call2 <- mc
  
  oldClass(out) <- c("solarAssoc", oldClass(out))
    
  return(out)
}
