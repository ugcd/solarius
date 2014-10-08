#' Function solarPolygenic.
#'
#' @export
solarPolygenic <- function(formula, data, 
  dir,
  polygenic.settings = "",  polygenic.options = "",
  verbose = 0,
  ...) 
{
  ### step 1: process par & create `out`
  mc <- match.call()
  
  stopifnot(!missing(formula), !missing(data))
  stopifnot(class(data) == "data.frame")
  stopifnot(length(polygenic.options) == 1)
  
  is.tmpdir <- missing(dir)
  
  # extract `traits`, `covlist`
  formula.str <- as.character(as.list(formula))

  traits <- unlist(strsplit(formula.str[[2]], "\\+"))
  traits <- gsub(" ", "", traits)

  covlist <- unlist(strsplit(formula.str[[3]], "\\+"))
  covlist <- gsub(" ", "", covlist)

  # default values of some par
  if(polygenic.options == "" & length(traits) == 1) {
    polygenic.options <- "-screen -all"
  }

  out <- list(traits = traits, covlist = covlist, 
    polygenic.settings = polygenic.settings, polygenic.options = polygenic.options, 
    call = mc)
  
  # check `traits`, `covlist`
  check_var_names(traits, covlist, names(data))

  ### step 2: set up SOLAR dir
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarPolygenic-")
  }
  if(verbose) cat(" * solarPolygenic: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` used\n")
 
  df2solar(data, dir)
  
  ### step 3: run polygenic
  out <- solar_polygenic(dir, out)
  
  ### clean 
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
    if(verbose > 1) cat("  -- solarPolygenic: temporary directory `", dir, "` unlinked\n")
  }
  
  oldClass(out) <- "solarPolygenic"  
  return(out)
}
