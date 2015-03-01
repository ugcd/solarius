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

  cat("\n Input IBD data:\n")
  cat("  *  directory ", x$multipoint$mibddir, "\n", sep = "")
  
  cat("\n Output results of association:\n")
  cat("\n  * Table of association results (first 5 out of ", nrow(x$lodf), " rows):\n", sep = "")
  print(head(x$lodf, 5))
  
  t <- x$multipoint$tprofile$cputime.sec
  cat("\n CPU time on ", x$multipoint$cores, " core(s): ", 
    format(.POSIXct(t, tz = "GMT"), "%H:%M:%S"), "\n", sep = "")
}

#' @method plot solarMultipoint
#' @export
plot.solarMultipoint <- function(x, 
  pass = 1, ...)
{
  if(!require(ggplot2)) {
    stop("`ggplot2` package is required for plotting")
  }
    
  ### check object `x`
  stopifnot(x$multipoint$num.passes >= pass)
  lodf <- switch(as.character(pass),
    "1" = x$lodf,
    "2" = x$lodf2,
    "3" = x$lodf3,
    stop("error in switch"))
    
  stopifnot(!is.null(lodf))
  stopifnot(class(lodf) == "data.frame")  
  stopifnot(all(c("pos", "LOD", "chr") %in% names(lodf)))
  
  ### plot parameters
  ymin <- min(min(lodf$LOD), 0)
  ymax <- max(max(lodf$LOD), 3)
  
  ### plot  
  ggplot(lodf, aes(pos, LOD)) + geom_line() + facet_wrap(~ chr, scales = "free_x") + 
    ylim(ymin, ymax) + labs(title = getFormula(x)) +
    theme_bw()
}

#' @method summary solarMultipoint
#' @export
summary.solarMultipoint <- function(x, ...)
{
  cat("\nCall: ")
  print(x$multipoint$call)
  
  cat("\nMultipoint model\n")
  cat(" * Number of used markers:", nrow(x$lodf), "\n")
  cat(" * Number of passes:", x$multipoint$num.passes, "\n")

  ind <- which.max(x$lodf$LOD)
  cat(" * Maximum LOD score:", round(x$lodf$LOD[ind], 2), "\n")
  cat("  -- chr:", x$lodf$chr[ind], "\n")
  cat("  -- position:", x$lodf$pos[ind], "cM\n")
}
