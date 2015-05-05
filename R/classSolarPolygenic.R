#' S3 class solarPolygenic.
#'
#' @name solarPolygenicClass
#' @rdname solarPolygenicClass
#' @exportClass solarPolygenic

#--------------------
# Print method
#--------------------

#' @rdname solarPolygenicClass
#' @export
print.solarPolygenic <- function(x, ...)
{
  cat("\nCall: ")
  print(x$call)
  
  cat("\nFile polygenic.out:\n")
  l_ply(x$solar$files$model$polygenic.out, function(x) cat(x, "\n"))
}

#' @rdname solarPolygenicClass
#' @export
summary.solarPolygenic <- function(object, ...)
{
  cat("\nCall: ")
  print(object$call)
  
  cat("\nFile polygenic.out:\n")
  l_ply(object$solar$files$model$polygenic.out, function(x) cat(x, "\n"))
  
  cat("\n Loglikelihood Table:\n")
  print(object$lf)
  
  cat("\n Covariates Table:\n")
  print(object$cf)

  cat("\n Variance Components Table:\n")
  print(object$vcf)
}

#--------------------
# Generic method
#--------------------

#' @rdname solarPolygenicClass
#' @export
residuals.solarPolygenic <- function(object, trait = FALSE, ...)
{
  stopifnot(!is.null(object$resf))
  stopifnot(nrow(object$resf) > 0)
  stopifnot(all(c("id", "residual") %in% names(object$resf)))
  
  if(!trait) {
    r <- object$resf$residual
    names(r) <- object$resf$id
  } else {
    stopifnot(length(object$traits) == 1)
    trait <- object$traits

    trait <- tolower(trait) # SOLAR naming in residual files
    stopifnot(trait %in% names(object$resf))
  
    r <- subset(object$resf, select = trait, drop = TRUE)
    names(r) <- object$resf$id
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
