#' Function solarPolygenic.
#'
#' @export
solarPolygenic <- function(formula, data, 
  dir,
  covtest = FALSE, screen = FALSE, household = FALSE,
  alpha = 0.05,
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

  # process `polygenic.settings`/`polygenic.options`
  if(length(traits) == 1) {
    polygenic.options <- paste(polygenic.options, "-prob", alpha)
  } else if(length(traits) == 2) {
    polygenic.options <- paste(polygenic.options, "-rhopse")
  }
  
  # parse `covtest`/`screen`/`household` par
  if(covtest) {
    polygenic.options <- paste(polygenic.options, "-screen -all")
  }
  if(screen) {
    polygenic.options <- paste(polygenic.options, "-screen")
  }
  if(household) {
    polygenic.settings <- c(polygenic.settings, "house")
    polygenic.options <- paste(polygenic.options, "-keephouse")
  }

  # check `traits`, `covlist`
  check_var_names(traits, covlist, names(data))

  out <- list(traits = traits, covlist = covlist, 
    polygenic.settings = polygenic.settings, polygenic.options = polygenic.options, 
    solar = list(model.filename = "null0.mod"),
    call = mc)
  
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
