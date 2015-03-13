#' Function solarPolygenic.
#'
#' @param formula
#'  an object of class \code{formula} or one that can be coerced to that class.
#'  It is a symbolic description of fixed effects (covariates) to be fitted. 
#'  If the model does not have any covariates, then the formula looks like 
#'  \code{trait ~ 1}, where \code{1} means the trait mean parameter.
#' @param data
#'    A data frame containing the variables in the model, 
#'    including ID fields needed to construct random effects: genetic and house-hold (both optional).
#'    Other classes such as list, environment or object coercible by \code{as.data.frame} to a data frame
#'    are not supported.
#' @param dir
#'    an optional character string, the name of directory,
#'    where SOLAR performs the analysis.
#'    In this case, the analysis within related input/output files is 
#'    conducted in the given folder instead of a temporary one
#'    (the default work flow).
#' @param kinship
#'    A matrix of the kinship coefficient (custom kinship matrix). 
#'    The IDs are required to be in row and column names.
#'    Currently, it does not work for unrelated individuals (SOLAR issue).
#' @param traits
#'    a vector of characters to specify trait(s) in the model. It is alternative to the formula interface.
#' @param covlist 
#'    a vector of characters to specify fixed effects (covariates) in the model.
#'    It is alternative to the formula interface.
#'    It could be convenient to indicate covariates in the SOLAR format,
#'    for example, \code{"age^1,2,3#sex"} that means \code{sex age agesex age^2 age^2sex age^3 age^3*sex}.
#'    The default value is \code{"1"}.
#' @param covtest 
#'    a logical value, indicating where to test the significance of the fixed effects (covariates).
#'    Likelihood ratio test (LRT) is used by SOLAR.
#'    \code{polygenic} SOLAR command is called with a combination of \code{-screen -all} options.
#'    As a result, \code{cf} slot will have p-values in \code{pval} column.
#'    The default value is \code{FALSE}.
#' @param screen 
#'    a logical value, indicating where to screen the fixed effects (covariates).
#'    \code{polygenic} SOLAR command is called with \code{-screen} option.
#'    As a result, only significant covariates will be maintained in the model.
#'    The default value is \code{FALSE}.
#' @param household The default value is \code{as.logical(NA)}.
#'    
#' @param transforms The default value is \code{character(0)}.
#' @param alpha The default value is \code{0.05}.
#' @param polygenic.settings The default value is \code{""}.
#' @param polygenic.options The default value is \code{""}.
#' @param verbose The default value is \code{0}.
#' 
#' @importFrom methods hasArg
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
