#' S3 class solarPolygenic.
#'
#' @name solarPolygenic-class
#' @rdname solarPolygenic-class
#' @exportClass solarPolygenic

#--------------------
# Print method
#--------------------

#' @rdname solarPolygenic-class
#' @export
print.solarPolygenic <- function(x, ...)
{
  cat("\nCall: ")
  print(x$call)
  
  cat("\nFile polygenic.out:\n")
  l_ply(x$solar$files$model$polygenic.out, function(x) cat(x, "\n"))
}

#' @rdname solarPolygenic-class
#' @export
summary.solarPolygenic <- function(x, ...)
{
  cat("\nCall: ")
  print(x$call)
  
  cat("\nFile polygenic.out:\n")
  l_ply(x$solar$files$model$polygenic.out, function(x) cat(x, "\n"))
  
  cat("\n Loglikelihood Table:\n")
  print(x$lf)
  
  cat("\n Covariates Table:\n")
  print(x$cf)

  cat("\n Variance Components Table:\n")
  print(x$vcf)
}

#--------------------
# Generic method
#--------------------

#' @rdname solarPolygenic-class
#' @export
residuals.solarPolygenic <- function(x, trait = FALSE, ...)
{
  stopifnot(!is.null(x$resf))
  stopifnot(nrow(x$resf) > 0)
  stopifnot(all(c("id", "residual") %in% names(x$resf)))
  
  if(!trait) {
    r <- x$resf$residual
    names(r) <- x$resf$id
  } else {
    stopifnot(length(x$traits) == 1)
    trait <- x$traits

    trait <- tolower(trait) # SOLAR naming in residual files
    stopifnot(trait %in% names(x$resf))
  
    r <- subset(x$resf, select = trait, drop = TRUE)
    names(r) <- x$resf$id
  }
  
  return(r)
}


#--------------------
# Other method
#--------------------

#' @export
getFormula <- function(x, ...)
{
  paste(
    paste(x$traits, collapse = "+"),
    "~",
    paste(x$covlist, collapse = "+"))
}
