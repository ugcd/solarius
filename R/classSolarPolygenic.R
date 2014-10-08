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
  
  cat("\npolygenic.out:\n")
  l_ply(x$files$model$polygenic.out, function(x) cat(x, "\n"))
}
