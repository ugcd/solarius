#' S3 class solarMultipoint.
#'
#' @name solarMultipointClass
#' @rdname solarMultipointClass
#'
#' @param x 
#'    An object of class \code{solarMultipoint}.
#' @param object
#'    An object of class \code{solarMultipoint}.
#' @param pass
#'    Integer argument for \code{plot} method, 
#'    indicating whether which pass in multi-passs linkage scan to be plotted.
#'    The default value is 1.
#' @param ...
#'    Additional arguments.
#'
#' @exportClass solarMultipoint

#--------------------
# Print method
#--------------------

#' @rdname solarMultipointClass
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

#' @rdname solarMultipointClass
#' @export
plot.solarMultipoint <- function(x, 
  pass = 1, ...)
{
  #if(!require(ggplot2)) {
  #  stop("`ggplot2` package is required for plotting")
  #}
    
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
  pos <- LOD <- chr <- NULL # R CMD check: no visible binding
  ggplot(lodf, aes(pos, LOD)) + geom_line() + facet_wrap(~ chr, scales = "free_x") + 
    ylim(ymin, ymax) + labs(title = getFormulaStr(x)) +
    theme_bw()
}

#' @rdname solarMultipointClass
#' @export
summary.solarMultipoint <- function(object, ...)
{
  cat("\nCall: ")
  print(object$multipoint$call)
  
  cat("\nMultipoint model\n")
  cat(" * Number of used markers:", nrow(object$lodf), "\n")
  cat(" * Number of passes:", object$multipoint$num.passes, "\n")

  ind <- which.max(object$lodf$LOD)
  cat(" * Maximum LOD score:", round(object$lodf$LOD[ind], 2), "\n")
  cat("  -- chr:", object$lodf$chr[ind], "\n")
  cat("  -- position:", object$lodf$pos[ind], "cM\n")
}


##' @export
tabplot <- function(object,...) UseMethod("tabplot") 

#' @rdname solarMultipointClass
#' @method tabplot solarMultipoint
#' @export
tabplot.solarMultipoint <- function(object, LOD.thr = 1.5, plot.null = TRUE, ...)
{
  stopifnot(require("gridExtra"))
  stopifnot(require("grid"))  
  
  # `sf`
  sf <- ddply(object$lodf, "chr", summarize, 
    pos = pos[which.max(LOD)],
    LOD.max = max(LOD))
  
  sf <- subset(sf, LOD.max > LOD.thr)
  
  if(nrow(sf) > 0) {
    ord <- with(sf, order(-LOD.max))
    sf <- sf[ord, ]
    
    rownames(sf) <- 1:nrow(sf)  
      
    N <- min(15, nrow(sf))
    sf <- sf[1:N, ]      
      
    sf <- mutate(sf,
      LOD.max = round(LOD.max, 2))
    
    grid::grid.newpage()
    gridExtra::grid.table(sf)
  } else {
    if(plot.null) {
      p <- qplot(1:10, 1:10, geom = "blank") + 
        theme_bw() +
        theme(line = element_blank(),
          text = element_blank())
      print(p)
    }
  }    
  
  return(invisible())  
}
