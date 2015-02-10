#' Function solarAssoc.
#'
#' @export
solarAssoc <- function(formula, data, dir,
  kinship,
  traits, covlist = "1",
  # input data to association 
  snpformat, snpdata, snpcovdata, snpmap,
  snplist, snpind,
  genocov.files, genolist.file, snplists.files, snpmap.files,
  # output data from association
  assoc.outformat = c("df", "outfile", "outfile.gz"), assoc.outdir, 
  # misc
  cores = getOption("cores"),
  ...,
  verbose = 0) 
{
  tsolarAssoc <- list()
  tsolarAssoc$args <- proc.time()
  
  ### step 1: process par & create `out`
  mc <- match.call()
  
  ### check if input files exist
  ret <- check_assoc_files_exist(genocov.files, snplists.files, snpmap.files)
  
  # missing parameters
  #if(missing(snpformat)) snpformat <- "012"
  
  # check for input data argument
  if(missing(snpdata) & missing(snpcovdata) & missing(genocov.files)) {
    stop("Error in `solarAssoc`: input SNP data must be given by either `snpdata`/`snpcovdata` or `genocov.files` arguments.")
  }

  if(!missing(snpdata) & !missing(snpcovdata)) {
    stop("Error in `solarAssoc`: input SNP data must be given by either `snpdata` or `snpcovdata` or `genocov.files` arguments.")
  }

  if(!missing(genocov.files)) {
    if(missing(snplists.files)) {
      stop("Error in `solarAssoc`: both genocov.files & snplists.files must be specified.")
    }
    if(length(genocov.files) > 1) {
      if(length(genocov.files) != length(snplists.files)) {
        stop("Error in `solarAssoc`: if several `genocov.files` (", length(genocov.files), 
          ") are given, then the same number of `snplists.files` (",length(snplists.files), ") is required.\n",
          "  --  SOLAR processes these files differently: `genocov.files` are processed one by one in the analysis chain, ",
          "while `snplists.files` are read all together before the analysis starts.\n",
          "  --  When several groups of files are given, SOLAR is called for each group independelty. ",
          "Groping, e.g. SNPS by chromosome, supposed to be under the user control (before SOLAR is called).")
      }
    }
  }

  assoc.informat <- ifelse(!missing(genocov.files), "genocov.file",
    ifelse(!missing(snpdata), "snpdata",
    ifelse(!missing(snpcovdata), "snpcovdata",
    stop("ifelse error in processing `assoc.informat`"))))
  if(assoc.informat == "genocov.file") {
    if(length(genocov.files) > 1) {
      assoc.informat <- "genocov.files"
    }
  }

  # check map files
  if(!missing(snpmap) & !missing(snpmap.files)) {
    stop("Error in `solarAssoc`: input SNP maps must be given by either `snpmap` or `snpmap.files` arguments.")
  }
  if(!missing(genocov.files) & !missing(snpmap.files)) {
    if(length(genocov.files) > 1) {
      if(length(genocov.files) != length(snpmap.files)) {
        stop("Error in `solarAssoc`: if several `genocov.files` (", length(genocov.files), 
          ") are given, then the same number of `snpmap.files` (",length(snplists.files), ") is required.")
      }
    }
  }  
  
  assoc.mapformat <- ifelse(!missing(snpmap.files), "snpmap.file",
    ifelse(!missing(snpmap), "snpmap", "default"))
  if(!missing(genocov.files) & !missing(snpmap.files)) {
    if(length(genocov.files) > 1) {
      if(assoc.mapformat == "snpmap.file") {
        stopifnot(length(genocov.files) == length(snpmap.files))
        assoc.mapformat <- "snpmap.files"
      }
    }
  }
    
  # check for matrix format  
  if(!missing(snpdata)) {
    stopifnot(class(snpdata) == "matrix")
  }
  if(!missing(snpcovdata)) {
    stopifnot(class(snpcovdata) == "matrix")
  }
  
  # check `snplist` / `snpind` format
  stopifnot(any(missing(snplist), missing(snpind)))
  
  assoc.snplistformat <- ifelse(all(missing(snplist), missing(snpind)), "default",
    ifelse(!missing(snplist), "snplist",
    ifelse(!missing(snpind), "snpind",
    stop("ifelse error in processing `snplistformat`"))))
  if(assoc.informat == "genocov.files") {
    if(assoc.snplistformat != "default") {
      stop("Error in `solarAssoc`: `snplist`/`snpind` is not allowd for `genocov.files` input format.")
    }
  }

  if(missing(snplist)) {
    snplist <-  character()
  }
  if(missing(snpind)) {
    snpind <- integer()
  }
  
  # check for output data arguments
  assoc.outformat <- match.arg(assoc.outformat)
    
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
  if(verbose > 1) cat(" * solarAssoc: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` used\n")

  ### step 3: compute a polygenic model by calling `solarPolygenic`
  tsolarAssoc$polygenic <- proc.time()
  out <- solarPolygenic(formula, data, dir,
    kinship, traits, covlist, ..., verbose = verbose)

  # make a copy of `dir`
  files.dir <- list.files(dir, include.dirs = TRUE, full.names = TRUE)
  dir.poly <- file.path(dir, "solarPolygenic")
  stopifnot(dir.create(dir.poly, showWarnings = FALSE, recursive = TRUE))
  stopifnot(file.copy(from = files.dir, to = dir.poly, recursive = TRUE))
  
  ### step 3.1: add assoc.-specific slots to `out`
  tsolarAssoc$preassoc <- proc.time()
  if(missing(genocov.files)) {
    genocov.files.local <- TRUE
    genocov.files <- "snp.genocov"
  } else {
    genocov.files.local <- FALSE
    genocov.files <- normalizePath(genocov.files)
  }
  
  if(missing(snplists.files)) {
    snplists.files.local <- TRUE
    snplists.files <- "snp.geno-list"
  } else {
    snplists.files.local <- FALSE
    snplists.files <- normalizePath(snplists.files)
  }
  if(missing(snpmap.files)) {
    snpmap.files <- character(0)
  } else {
    snpmap.files <- normalizePath(snpmap.files)
  }
  
  out$assoc <- list(call = mc, #snpformat = snpformat,
    cores = cores,
    # input par
    snplist = snplist, snpind = snpind,
    # input/output files
    dir.poly = dir.poly,
    genocov.files = genocov.files, genocov.files.local = genocov.files.local,
    genolist.file = "snp.geno-list", 
    snplists.files = snplists.files, snplists.files.local = snplists.files.local,
    snpmap.files = snpmap.files,
    out.dirs = "assoc", out.files = "assoc.out",
    # input/output data for association
    assoc.informat = assoc.informat,
    assoc.outformat = assoc.outformat,
    assoc.snplistformat = assoc.snplistformat,
    assoc.mapformat = assoc.mapformat,
    tprofile = list(tproc = list()))

  ### step 4: add genotype data to `dir`
  #snpdata <- format_snpdata(snpdata, snpformat)

  # maps (load previously to loading snp data)
  # -- SOLAR does not use this info. in assoc. analysis 
  #    neither output to the results file
  #if(!missing(snpmap)) {
  #  ret <- snpmap2solar(snpmap, dir)
  #}
  
  if(out$assoc$assoc.informat == "snpdata") {
    ret <- snpdata2solar(snpdata, dir)
  } else if(out$assoc$assoc.informat == "snpcovdata") {
    ret <- snpcovdata2solar(snpcovdata, out, dir)
  }
  
  ### number of snps
  num.snps <- as.integer(NA)
  if(out$assoc$assoc.informat %in% c("snpdata", "snpcovdata")) {
    snps <- readLines(file.path(dir, out$assoc$genolist.file))
    num.snps <- length(snps)
  }

  out$assoc$num.snps <- num.snps
    
  ### step 6: prepare data for parallel computation (if necessary)
  out <- prepare_assoc_files(out, dir)
  
  ### step 7: run assoc  
  tsolarAssoc$runassoc <- proc.time()
  out <- run_assoc(out, dir)
  
  ### step 8: set keys
  tsolarAssoc$keyresults <- proc.time()
  if(class(out$snpf)[1] == "data.table") {
    setkey(out$snpf, SNP)
  }
  
  ### step 9: try to add mapping information
  ret <- suppressWarnings(try({
  if(out$assoc$assoc.mapformat == "snpmap") {
    # read map
    tsolarAssoc$map <- proc.time()
    snpmap <- as.data.table(snpmap)
    
    renames <- match_map_names(names(snpmap))
    snpmap <- rename(snpmap, renames)
    
    snpmap <- subset(snpmap, select = renames)
    setkey(snpmap, SNP)
    
    # annotate 
    tsolarAssoc$annotate <- proc.time()
    out$snpf <- data.table:::merge.data.table(out$snpf, snpmap, by = "SNP", all.x = TRUE)
  } else if(out$assoc$assoc.mapformat %in% c("snpmap.file", "snpmap.files")) {
    # read map
    tsolarAssoc$map <- proc.time()
    snpmap <- read_map_files(out$assoc$snpmap.files, cores = out$assoc$cores)
    
    renames <- match_map_names(names(snpmap))
    snpmap <- rename(snpmap, renames)
    
    snpmap <- subset(snpmap, select = renames)
    setkey(snpmap, SNP)
    
    # annotate 
    tsolarAssoc$annotate <- proc.time()
    out$snpf <- data.table:::merge.data.table(out$snpf, snpmap, by = "SNP", all.x = TRUE)
  }
  }, silent = TRUE))
  
  ### clean 
  unlink(dir.poly, recursive = TRUE)
  
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
    if(verbose > 1) cat("  -- solarAssoc: temporary directory `", dir, "` unlinked\n")
  }

  ### return
  tsolarAssoc$return <- proc.time()
  out$assoc$tprofile$tproc$tsolarAssoc <- tsolarAssoc

  out$assoc$tprofile <- try({
    procc_tprofile(out$assoc$tprofile)
  }, silent = TRUE)
  
  oldClass(out) <- c("solarAssoc", oldClass(out))
  return(out)
}

prepare_assoc_files <- function(out, dir)
{  
  stopifnot(!is.null(out$assoc$cores))
  stopifnot(!is.null(out$assoc$genocov.files))
  stopifnot(!is.null(out$assoc$out.dirs))
  stopifnot(!is.null(out$assoc$out.files))

  assoc.snplistformat <- out$assoc$assoc.snplistformat
  assoc.informat <- out$assoc$assoc.informat
  
  cores <- out$assoc$cores

  genocov.files <- out$assoc$genocov.files
  snplists.files0 <- out$assoc$snplists.files
  genolist.file0 <- out$assoc$genolist.file
  snplists.files.local <- out$assoc$snplists.files.local
  
  out.dirs0 <- out$assoc$out.dirs
  out.files0 <- out$assoc$out.files

  snplists.files.local <- out$assoc$snplists.files.local

  ### case 1
  if(assoc.informat == "genocov.files") {
    stopifnot(length(genocov.files) == length(snplists.files0))
    
    snplists.files <- snplists.files0
    num.gr <- length(genocov.files)
    
    out.dirs <- rep(as.character(NA), num.gr)
    out.files <- rep(as.character(NA), num.gr)

    for(k in 1:num.gr) {
      out.dirs[k] <- paste(out.dirs0, k, sep = "")
      out.files[k] <- paste(out.files0, k, sep = "")
    }
  ### case 2
  } else {
    #### sub-case: `snplistformat` is `snplist`/`snpind`
    if(assoc.snplistformat == "snplist") {
      snplists.files <- genolist.file0
      
      writeLines(out$assoc$snplist, file.path(dir, snplists.files))

      snplists.files0 <- snplists.files
      snplists.files.local <- TRUE
    } else if(assoc.snplistformat == "snpind") {
      snplists.files <- genolist.file0
    
      if(snplists.files.local) {
        snps <- unlist(llply(file.path(dir, snplists.files0), function(x) readLines(x)))  
      } else {
        snps <- unlist(llply(snplists.files0, function(x) readLines(x)))
      }
      num.snps <- length(snps)
      stopifnot(all(out$assoc$snpind <= num.snps))
      
      snplist <- snps[out$assoc$snpind]
      writeLines(snplist, file.path(dir, snplists.files))

      snplists.files0 <- snplists.files
      snplists.files.local <- TRUE
    }
    
    if(cores == 1) {
      snplists.files <- snplists.files0
      out.dirs <- out.dirs0
      out.files <- out.files0
    } else {
    ### case 3
    # - use `genolist.file` to split lists of SNPs
      ### number of snps
      if(snplists.files.local) {
        snps <- unlist(llply(file.path(dir, snplists.files0), function(x) readLines(x)))  
      } else {
        snps <- unlist(llply(snplists.files0, function(x) readLines(x)))
      }
      num.snps <- length(snps)

      num.gr <- cores 
      gr <- cut(1:num.snps, breaks = seq(1, num.snps, length.out = num.gr + 1), include.lowest = TRUE)

      snplists.files <- rep(as.character(NA), num.gr)
      out.dirs <- rep(as.character(NA), num.gr)
      out.files <- rep(as.character(NA), num.gr)

      for(k in 1:nlevels(gr)) {
        snplists.files.k <- paste(genolist.file0, k, sep = "")
        out.dirs.k <- paste(out.dirs0, k, sep = "")
        out.files.k <- paste(out.files0, k, sep = "")
        
        gr.k <- levels(gr)[k]
        snps.k <- snps[gr %in% gr.k]
    
        writeLines(snps.k, file.path(dir, snplists.files.k))
        
        snplists.files[k] <- snplists.files.k
        out.dirs[k] <- out.dirs.k
        out.files[k] <- out.files.k
      }
      snplists.files.local <- TRUE
    }
  }
  stopifnot(all(!is.na(snplists.files)))
  stopifnot(all(!is.na(out.dirs)))
  stopifnot(all(!is.na(out.files)))

  out$assoc$snplists.files <- snplists.files
  out$assoc$out.dirs <- out.dirs
  out$assoc$out.files <- out.files
  out$assoc$snplists.files.local <- snplists.files.local

  return(out)
}

run_assoc <- function(out, dir)
{ 
  trun_assoc <- list()
  trun_assoc$args <- proc.time()
  
  cores <- out$assoc$cores
    
  genocov.files <- out$assoc$genocov.files
  snplists.files <- out$assoc$snplists.files
  out.dirs <- out$assoc$out.dirs
  out.files <- out$assoc$out.files
  
  ### run
  trun_assoc$solar <- proc.time()
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
    num.genocov.files <- length(genocov.files)
    out.gr <- llply(1:num.genocov.files, function(i) {
      if(out$verbose) {
         cat(" * solarAssoc: ", i, "/", num.genocov.files, "genocov.files...\n")
      }
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
  trun_assoc$results <- proc.time()
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
  trun_assoc$return <- proc.time()
  out$assoc$tprofile$tproc$trun_assoc <- trun_assoc
      
  return(out)
}
