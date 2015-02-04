#' S3 class solarMultipoint.
#'
#' @exportClass solarMultipoint

#--------------------
# Print method
#--------------------

#' @method print solarMultipoint
#' @export
print.solarMultipoint <- function(x, ...)
{
  cat("\nCall: ")
  print(x$multipoint$call)
}
