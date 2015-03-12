#' S3 class solarAssoc.
#'
#' @name solarAssoc-class
#' @rdname solarAssoc-class
#' @exportClass solarAssoc

#--------------------
# Print method
#--------------------

#' @rdname solarAssoc-class
#' @export
print.solarAssoc <- function(x, ...)
{
  cat("\nCall: ")
  print(x$assoc$call)
  
  cat("\n Input SNP data:\n")
  switch(x$assoc$assoc.informat,
    "snpdata" = cat("  *  ", x$assoc$num.snps, " SNP genotypes passed by `snpdata` argument\n", sep = ""),
    "snpcovdata" = cat("  *  ", x$assoc$num.snps, " SNP covariates passed by `snpcovdata` argument\n", sep = ""),
    "genocov.file" = cat("  *  SNP covariates passed in ", length(x$assoc$genocov.files),
      " file(s) by `genocov.files` argument\n", sep = ""),
    "genocov.files" = cat("  *  SNP covariates passed in ", length(x$assoc$genocov.files),
      " file(s) by `genocov.files` argument and ", length(x$assoc$snplists.files), 
      " files(s) by `snplists.files` argument\n", sep = ""),
    stop("switch error")
  )
  
  cat("\n Output results of association:\n")
  if(x$assoc$assoc.outformat == "df") {
    cat("\n  *  Table of association results (first 5 out of ", nrow(x$snpf), " rows):\n", sep = "")
    print(head(x$snpf, 5))
  }
  #cat("  *  assoc.outformat: ", x$assoc$assoc.outformat, "\n", sep = "")
  
  t <- x$assoc$tprofile$cputime.sec
  cat("\n CPU time on ", x$assoc$cores, " core(s): ", 
    format(.POSIXct(t, tz = "GMT"), "%H:%M:%S"), "\n", sep = "")
}

#' @rdname solarAssoc-class
#' @export
plot.solarAssoc <- function(x, y = "manh", ...)
{
  switch(y,
    manh = ManhattanPlot(x, ...),
    qq = qqPlot(x, ...),
    stop("switch error"))
}

plot.solarAssoc.old <- function(x, 
  alpha = 0.05, corr = "BF", pval = "pval", ...)
{
  ret <- require(ggplot2)
  if(!ret) {
    stop("`ggplot2` package is required for plotting")
  }
  ret <- require(scales)
  if(!ret) {
    stop("`scales` package is required for plotting")
  }
    
  df <- x$snpf
  N <- nrow(df)
  
  ord <- order(df$pSNP)
  df <- df[ord, ]
  df$ord <- 1:nrow(df)
    
  ### multiple-test correction  
  df <- within(df, {
    qSNP <- switch(corr,
      "BF" = pSNP * nrow(df),
      stop("switch error (1) in `plot.solarAssoc`"))
  })

  df <- mutate(df,
    signif = qSNP < alpha)
  
  num.signif <- sum(df$signif)
  
  ### subset
  num.nonsignif <- ifelse(num.signif, 3, 5)
  ord.nonsignif <- seq(1, num.nonsignif) + num.signif
  
  ### `pf` data frame for plotting
  pf <- rbind(subset(df, signif),
    subset(df, ord %in% ord.nonsignif))
  
  ord <- order(pf$ord)
  pf <- pf[ord, ]
  
  ### plotting settings
  # custom axis transformations in ggplot2
  #  - @ http://www.numbertheory.nl/2012/08/14/custom-axis-transformations-in-ggplot2/
  #  - @ http://stackoverflow.com/questions/11053899/how-to-get-a-reversed-log10-scale-in-ggplot2
  reverselog_trans <- function(base = exp(1)) 
  {
    trans <- function(x) -log(x, base)
    inv <- function(x) base^(-x)
    trans_new(paste0("reverselog-", format(base)), trans, inv, 
      log_breaks(base = base), 
      domain = c(1e-100, Inf))
  }
  
  xbreaks <- pf$ord
  xlables <- pf$SNP

  p <- switch(pval,
    "pval" = ggplot(pf, aes(ord, pSNP)) + geom_point() + 
      geom_segment(aes(x = ord, xend = ord, y = 1, yend = pSNP)) + 
      geom_hline(yintercept = alpha/N),
    "qval" = ggplot(pf, aes(ord, qSNP)) + geom_point() + 
      geom_segment(aes(x = ord, xend = ord, y = 1, yend = qSNP)) + 
      geom_hline(yintercept = alpha/N),
      stop("switch error (2) in `plot.solarAssoc`"))

  ylab <- switch(pval,
    "pval" = paste("P-value (alpha = ", format(alpha), ", ", "alpha/N = ", format(alpha/N), ")", sep = ""),
    "qval" = paste("Q-value (corrected p-value) (alpha = ", format(alpha), ")", sep = ""),
     stop("switch error (3) in `plot.solarAssoc`"))
  
  title <- paste("Association model: ", num.signif, " significant, N = ", N, sep = "")
    
  p <- p + scale_y_continuous(trans = reverselog_trans(10)) + 
    scale_x_continuous(breaks = xbreaks, labels = xlables) + 
    labs(y = ylab, x = "SNP", title = title) +
    coord_flip()
  
  return(p)
}

#' @rdname solarAssoc-class
#' @export
summary.solarAssoc <- function(x, alpha = 0.05, ...)
{
  cat("\nCall: ")
  print(x$assoc$call)
  
  ### var
  num.snps <- nrow(x$snpf)
  
  cat("\nAssociation model\n")
  cat(" * Number of SNPs:", num.snps, "\n")
  cat(" * Input format:", x$assoc$assoc.informat, "\n")
  
  # signif. SNPs
  pSNP.thr <- alpha / num.snps
  snpf <- subset(x$snpf, pSNP < pSNP.thr)
  num.snps.signif <- length(which(x$snpf$pSNP<pSNP.thr))
  cat(" * Number of significal SNPs:", num.snps.signif, "\n")
  if(num.snps.signif > 0) {
    ord <- with(snpf, order(pSNP))
    snpf <- snpf[ord, ]
    print(snpf, 5)
  }
}

#--------------------
# Other methods
#--------------------

#' @rdname solarAssoc-class
#' @export
annotate.solarAssoc <- function(x, ..)
{
  annotateSignifSNPs(x, ...)
}
