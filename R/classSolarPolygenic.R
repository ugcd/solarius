#' S3 class salamboPolygenic.
#'
#' @exportClass solarPolygenic

#--------------------
# Print method
#--------------------

#' @S3method print solarPolygenic
print.solarPolygenic <- function(x, ...)
{
  cat("\nCall: ")
  print(x$call)
  
  cat("\nFile polygenic.out:\n")
  l_ply(x$solar$files$model$polygenic.out, function(x) cat(x, "\n"))
}

#' @S3method summary solarPolygenic
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
