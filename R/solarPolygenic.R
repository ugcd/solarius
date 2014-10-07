#' Function solarPolygenic.
#'
#' @export
solarPolygenic <- function(formula, data, 
  dir,
  polygenic.settings = list(),  polygenic.options = list(),
  verbose = 2,
  ...) 
{
  ### step 1: process par & create `out`
  mc <- match.call()
  
  stopifnot(!missing(formula), !missing(data))
  stopifnot(class(data) == "data.frame")

  is.tmpdir <- missing(dir)
  
  # extract `traits`, `covlist`
  formula.str <- as.character(as.list(formula))

  traits <- unlist(strsplit(formula.str[[2]], "\\+"))
  traits <- gsub(" ", "", traits)

  covlist <- unlist(strsplit(formula.str[[3]], "\\+"))
  covlist <- gsub(" ", "", covlist)

  out <- list(traits = traits, covlist = covlist, 
    polygenic.settings = polygenic.settings, polygenic.options = polygenic.options, 
    call = mc)
  
  # check `traits`, `covlist`
  stopifnot(all(traits %in% names(data)))
  
  covlist2 <- covlist
  # filter out term 1
  ind <-  grep("1", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  # filter out interaction terms with `*`
  ind <-  grep("\\*", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  # filter out power terms with "^"
  ind <-  grep("\\^", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  stopifnot(all(covlist2 %in% names(data)))
  
  ### step 2: set up SOLAR dir
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarPolygenic-")
  }
  if(verbose) cat(" * solarPolygenic: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` created\n")
  
  ### clean 
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
    if(verbose > 1) cat("  -- solarPolygenic: temporary directory `", dir, "` unlinked\n")
  }
  
  oldClass(out) <- "solarPolygenic"  
  return(out)
}
