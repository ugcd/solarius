
#------------------------------
# Main functions (out.globals)
#------------------------------

#' @export
solarPar <- function(mod, par)
{
  switch(class(mod)[1],
    "solarPolygenic" = switch(par,  
      "rhog" = ifelse(is.null(mod$vcf), as.numeric(NA), with(mod$vcf, Estimate[varcomp == "rhog"])),
      "rhog.se" = ifelse(is.null(mod$vcf), as.numeric(NA), with(mod$vcf, SE[varcomp == "rhog"])),
      "rhog.pval" = ifelse(is.null(mod$lf), as.numeric(NA), with(mod$lf, pval[model == "rhog0"])),
      "rhop" = solarParRhoP(mod),
      "rhop.se" = solarParRhoPSE(mod),
      "rhop.pval" = solarParRhoPP(mod),
      stop(paste0("switch for `par` value ", par, ", class solarPolygenic"))),
    "try-error" = as.numeric(NA),
    stop("switch for model class")
  )
}

#' @export
solarParIndividuals <- function(mod) extract_out_globals(mod, "SOLAR_Individuals")

#' @export
solarParH2rP <- function(mod) extract_out_globals(mod, "SOLAR_H2r_P")

#' @export
solarParKurtosis <- function(mod) extract_out_globals(mod, "SOLAR_Kurtosis")

#' @export
solarParCovlistP <- function(mod) extract_out_globals(mod, "SOLAR_Covlist_P")

#' @export
solarParCovlistChi <- function(mod) extract_out_globals(mod, "SOLAR_Covlist_Chi")

#' @export
solarParRhoP <- function(mod) extract_out_globals(mod, "SOLAR_RhoP")

#' @export
solarParRhoPSE <- function(mod) extract_out_globals(mod, "SOLAR_RhoP_SE")

#' @export
solarParRhoPP <- function(mod) extract_out_globals(mod, "SOLAR_RhoP_P")

#' @export
solarParRhoPOK <- function(mod) extract_out_globals(mod, "SOLAR_RhoP_OK")


#------------------------------
# Main functions (files *.mod)
#------------------------------

#' @export
solarParPvar <- function(mod, modelname = "null0.mod") extract_mod_pvar(mod, modelname)

#------------------------------
# Derived functions (explained variance)
#------------------------------

#' @export
explainedVarProp <- function(mod)
{
  covlist <- mod$covlist
  ncovlist <- length(covlist)
  if(ncovlist == 1 & covlist[1] == "1") {
    ncovlist <- 0
  }
  
  var.poly <- solarParPvar(mod, "null0.mod")
  var.nocovar <- solarParPvar(mod, "nocovar.mod")
    
  var.all <- 1 - var.poly / var.nocovar    
  out <- var.all
  names(out) <- "all"
    
  if(ncovlist) {
    out.covlist <- laply(covlist, function(cov) {
      var.cov <- solarParPvar(mod, paste0("no", cov, ".mod"))
      var.cov <- 1 - var.poly / var.cov
        
      return(var.cov)
    })
    
    out <- c(out, out.covlist)
    names(out) <- c("all", covlist)
  }
    
  tab <- data.frame(covariate = names(out), explainedVarProp = out, stringsAsFactors = FALSE)
  rownames(tab) <- NULL
    
  return(tab)
}

#-----------------------
# Support functions
#-----------------------

extract_out_globals <- function(mod, pat)
{
  lines <- mod$solar$files$model$out.globals
  
  if(is.null(lines)) {
    return(as.numeric(NA))
  }
  
  str <- gsub(pat, "", grep(pat, lines, value = TRUE))
  vals <- strsplit(str, " ")[[1]]
  vals <- vals[vals != ""]

  vals <- as.numeric(vals)

  if(length(vals) == 0) {
    vals <- as.numeric(NA)
  } else if (grepl("Covlist", pat)) {
    stopifnot(length(vals) == length(mod$covlist))
    names(vals) <- mod$covlist
  } 
  
  return(vals)
}

extract_mod_pvar <- function(mod, modelname)
{
  sd <- as.numeric(strsplit(grep("sd", mod$solar$files$model[[modelname]], value = TRUE)[1], "sd = |Lower")[[1]][2])
  sd^2
}














