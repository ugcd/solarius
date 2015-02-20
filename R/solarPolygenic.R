#' Function solarPolygenic.
#'
#' @importFrom methods hasArg
#' 
#' @export
solarPolygenic <- function(formula, data, dir,
  kinship,
  traits, covlist = "1",
  covtest = FALSE, screen = FALSE, household = as.logical(NA),
  transforms = character(0),
  alpha = 0.05,
  polygenic.settings = "",  polygenic.options = "",
  verbose = 0,
  ...) 
{
  ### step 1: process par & create `out`
  mc <- match.call()
  is.kinship <- methods::hasArg(kinship)
  
  stopifnot(!missing(data))
  stopifnot(class(data) == "data.frame")
  stopifnot(length(polygenic.options) == 1)
  
  stopifnot(!missing(formula) | (!missing(traits)))
  
  is.tmpdir <- missing(dir)
  
  # extract `traits`, `covlist`
  if(!missing(formula)) {
    formula.str <- as.character(as.list(formula))

    traits <- unlist(strsplit(formula.str[[2]], "\\+"))
    traits <- gsub(" ", "", traits)

    covlist <- unlist(strsplit(formula.str[[3]], "\\+"))
    covlist <- gsub(" ", "", covlist)
  }
  
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
  
  # force `household <- FALSE` if the data set does not have the house-hold field
  if(is.na(household) & !hasHousehold(names(data))) {
    household <- FALSE
  }
  # set up `polygenic.settings`
  if(is.na(household)) {
    polygenic.settings <- c(polygenic.settings, "house")
  } else if(household) {
    polygenic.settings <- c(polygenic.settings, "house")
    polygenic.options <- paste(polygenic.options, "-keephouse")
  } 
  ###
  # in the case `household == FALSE`, the house-hold effect will be ignored, 
  # as `house` SOLAR command in `polygenic.settings` is NOT set.
    
  # kinship
  kin2.gz <- "kin2.gz" # "phi2.gz" "kin2.gz"
  if(is.kinship) {
    polygenic.settings <- c(polygenic.settings, paste("matrix load", kin2.gz, "phi2"))
  }

  # check `traits`, `covlist`
  check_var_names(traits, covlist, names(data))

  out <- list(traits = traits, covlist = covlist, transforms = transforms,
    polygenic.settings = polygenic.settings, polygenic.options = polygenic.options, 
    solar = list(model.filename = "null0.mod", phe.filename = "dat.phe", 
      kin2.gz = kin2.gz, kinship = is.kinship),
    call = mc, verbose = verbose)
  
  ### step 2.1: transform
  if(length(out$transforms)) {
    if(length(out$transforms) == 1) {
      if(is.null(names(out$transforms))) {
        names(out$transforms) <- traits
      }      
    }
    stopifnot(all(names(out$transforms) %in% traits))
    
    # transform
    data <- transformData(out$transforms, data, ...)
    # change `traits` names
    for(t in names(out$transforms)) {
      ind <- which(out$traits == t)
      stopifnot(length(ind) == 1)
      
      out$traits[] <- paste0("tr_", t)
    }
  }
  
  ### step 2.2: set up SOLAR dir
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarPolygenic-")
  }
  if(verbose > 1) cat(" * solarPolygenic: parameter `dir` is missing.\n")
  if(verbose > 1) cat("  -- temporary directory `", dir, "` used\n")
 
  if(missing(kinship)) df2solar(data, dir)
  else df2solar(data, dir, kinship, kin2.gz = out$solar$kin2.gz)
  
  ### step 3: run polygenic
  out <- solar_polygenic(dir, out)
  
  ### step 3.1: residual polygenic
solar_read_residuals <- function(dir, out)
{
  stopifnot(file.exists(dir))
  traits.dir <- paste(out$traits, collapse = ".")
  file.residuals <- file.path(dir, traits.dir, "polygenic.residuals")
  
  ### line 1
  line1 <- readLines(file.residuals, n = 1)
  ncol <- length(strsplit(line1, ",")[[1]])
  colClasses <- rep(as.character(NA), ncol)
  colClasses[1] <- "character" # `id`
  
  tab <- read.table(file.residuals, header = TRUE, sep = ",", colClasses = colClasses)
  stopifnot(ncol(tab) == ncol)

  return(tab)
}

  ret <- suppressWarnings(try(solar_read_residuals(dir, out), silent = TRUE))
  #ret <- try(solar_read_residuals(dir, out))
  
  if(class(ret)[1] == "try-error") {
    out$resf <- data.frame()
  } else {
    out$resf <- ret
  }
  
  ### clean 
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
    if(verbose > 1) cat("  -- solarPolygenic: temporary directory `", dir, "` unlinked\n")
  }
  
  oldClass(out) <- "solarPolygenic"  
  return(out)
}
