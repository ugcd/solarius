#' Run association analysis via polygenic model.
#'
#' @export
solarPolyAssoc <- function(formula, data, dir, kinship, 
  traits, covlist = "1",
  # input data to association 
  snpcovdata, snplist, snpind,
  assoc.options = "",
  ...,
  verbose = 0) 
{
  stopifnot(requireNamespace("tools"))

  tsolarPolyAssoc <- list()
  tsolarPolyAssoc$args <- proc.time()

  ### Step 1: Arguments
  mc <- match.call()
    
  if(!missing(snpcovdata)) {
    stopifnot(class(snpcovdata) == "matrix")
  }
  
  # check `snplist` / `snpind` format
  stopifnot(any(missing(snplist), missing(snpind)))
  
  if(missing(snplist)) {
    snplist <-  character()
  }
  if(missing(snpind)) {
    snpind <- integer()
  }
  
  is.tmpdir <- missing(dir)
  
  ### step 2: process `snpcovdata`
  if(length(snplist)) {
    stopifnot(all(snplist %in% colnames(snpcovdata)))
    snpcovdata <- snpcovdata[, snplist, drop = FALSE]
  }
  if(length(snpind)) {
    stopifnot(all(snpind <= ncol(snpcovdata)))
    snpcovdata <- snpcovdata[, snpind, drop = FALSE]
  }
  
  snps <- colnames(snpcovdata)
  num.snps <- length(snps)
  snpcovdata <- data.frame(ID = rownames(snpcovdata), snpcovdata, stringsAsFactors = FALSE)
  
  fields <- matchIdNames(names(data))
  id.field <- names(fields)[1]

  names(snpcovdata)[1] <- id.field
  
  stopifnot(!any(names(snpcovdata)[-1] %in% names(data)))
  gdata <- merge(data, snpcovdata, by = id.field, all = TRUE)
  
  ### step 3: SOLAR dir
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarPolyAssoc-")
  }
  if(verbose > 1) cat(" * solarPolyAssoc: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` used\n")

  ### Step 4: compute a polygenic model by calling `solarPolygenic`
  tsolarPolyAssoc$polygenic <- proc.time()

  if(!missing(formula)) {
    formula <- update(formula, paste0("~ . + ", snps[1], "()"))
  } else {
    covlist <- c(covlist, paste0(snps[1], "()"))
  }
  
  out <- solarPolygenic(formula, gdata, dir,
    kinship, traits, covlist, ..., verbose = verbose)

  out$assoc <- list(call = mc,
    cores = 1,
    snps = snps, num.snps = num.snps,
    # input par
    snplist = snplist, snpind = snpind,
    assoc.informat = "snpcovdata", assoc.outformat = "df",
    # SOLAR options/settings
    assoc.options = assoc.options)

  ### Step 4.1: add assoc.-specific slots to `out`
  tsolarPolyAssoc$preassoc <- proc.time()

  ### step 5: run assoc  
  tsolarPolyAssoc$runassoc <- proc.time()
  
  model.path <- paste0(paste(out$traits, collapse = "."), "/", tools::file_path_sans_ext(out$solar$model.filename))
  if(FALSE) {
    cmd.proc_def <- c(get_proc_poly_assoc(snps))
    cmd.proc_call <- c(paste0("poly_assoc ", "\"", model.path, "\""))
  
    cmd <- c(cmd.proc_def, cmd.proc_call)
    ret <- solar(cmd, dir, result = TRUE)
  } else {
    if(length(out$traits) == 1) {
      cmd.proc_def <- c(get_proc_poly_assoc2(snps, "sex*$snp", 2))
      cmd.proc_call <- c(paste0("poly_assoc2 ", "\"", model.path, "\""))
  
      cmd <- c(cmd.proc_def, cmd.proc_call)
      ret <- solar(cmd, dir, result = TRUE)
    } else if(length(out$traits) == 2) {
      cmd.proc_def <- c(get_proc_poly_assoc2(snps, paste0("${snp}_2(", out$traits[2], ")"), 2))
      cmd.proc_call <- c(paste0("poly_assoc2 ", "\"", model.path, "\""))
  
      cmd <- c(cmd.proc_def, cmd.proc_call)
      ret <- solar(cmd, dir, result = TRUE)
    }
  }
  
  snpf <- try({
    tab <- fread(file.path(dir, "out.poly.assoc"), sep = " ", header = FALSE)
    if(ncol(tab) == 4) {
      setnames(tab, c("SNP", "pSNP", "pSNPc", "pSNPi"))
    }
  })
  out$snpf <- snpf
  
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
    if(verbose > 1) cat("  -- solarPolyAssoc: temporary directory `", dir, "` unlinked\n")
  }

  ### return
  tsolarPolyAssoc$return <- proc.time()
  out$assoc$tprofile$tproc$tsolarPolyAssoc <- tsolarPolyAssoc

  out$assoc$tprofile <- try({
    procc_tprofile(out$assoc$tprofile)
  }, silent = TRUE)
  
  oldClass(out) <- c("solarAssoc", oldClass(out), "solarPolyAssoc")
  return(out)
}


get_proc_poly_assoc <- function(snps)
{
paste0("proc poly_assoc {model} {\
\
  # model 0\
	load model $model\
	set loglike_0 [loglike]\
\
  # write to file\
	set f [open \"out.poly.assoc\" \"w\"]\
	foreach snp [list ", paste(snps, collapse = " "), "] {\
	  # model 1\
	  covariate $snp\
	  polymod\
	  maximize\
	  set loglik_1 [loglike]\
	  \
	  puts $f \"$snp $loglike_0 $loglik_1\"\
	}\
	close $f\
}\
")
}

get_proc_poly_assoc2 <- function(snps, cov2, df2)
{
paste0("proc poly_assoc2 {model} {\
\
  # write to file\
	set f [open \"out.poly.assoc\" \"w\"]\
	foreach snp [list ", paste(snps, collapse = " "), "] {\
	  # extra variable\
	  define ${snp}_2 = $snp\
	  \
    # model 0\
	  load model $model\
	  set loglike_0 [loglike]\
    \
	  # model 1\
	  load model $model\
	  set pval_common \"NA\"\
	  \
	  covariate $snp\
	  polymod\
	  if {![catch {maximize -q}]} {\
  	  set loglike_1 [loglike]\
	    \
	    set D [expr 2 * ($loglike_1 - $loglike_0)]\
	    if {$D < 0} {\
	      set pval_common 1\
	    } else {\
  	    set pval_common [chi -number $D 1]\
  	  }\
	  }\
	  \
	  # model 2\
	  load model $model\
	  set pval_interaction \"NA\"\
	  set pval_full \"NA\"\
	  \
	  covariate $snp ", cov2, "\
	  polymod\
	  if {![catch {maximize -q}]} {\
  	  set loglike_2 [loglike]\
	    \
	    set D [expr 2 * ($loglike_2 - $loglike_1)]\
	    if {$D < 0} {\
	      set pval_interaction 1\
	    } else {\
  	    set pval_interaction [chi -number $D 1]\
  	  }\
      \
	    set D [expr 2 * ($loglike_2 - $loglike_0)]\
	    if {$D < 0} {\
	      set pval_full 1\
	    } else {\
  	    set pval_full [chi -number $D ", df2, "]\
  	  }\
	  }\
	  \
	  # put\
	  #puts $f \"$snp $loglike_0 $loglik_1 $loglike_2\"\
	  puts $f \"$snp $pval_full $pval_common $pval_interaction\"\
	}\
	close $f\
}\
")
}
