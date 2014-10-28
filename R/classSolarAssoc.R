#' S3 class solarAssoc.
#'
#' @exportClass solarAssoc

#--------------------
# Print method
#--------------------

#' @method print solarAssoc
#' @export
print.solarAssoc <- function(x, ...)
{
  cat("\nCall: ")
  print(x$call2)
}

#' @method plot solarAssoc
#' @export
plot.solarAssoc <- function(x, 
  alpha = 0.05, corr = "BF", pval = "pval", ...)
{
  df <- x$snpf
  N <- nrow(df)
  
  ### multiple-test correction  
  df <- within(df, {
    qSNP <- switch(corr,
      "BF" = pSNP * nrow(df),
      stop("switch error (1) in `plot.solarAssoc`"))
  })

  df <- mutate(df,
    signif = qSNP < alpha)
  
  num.signif <- sum(df$signif)
  
  ### order
  df <- mutate(df, 
    ord  = order(qSNP))
    
  ### subset
  num.nonsignif <- 3
  ord.nonsignif <- seq(1, num.nonsignif) + num.signif
  
  ### `pf` data frame for plotting
  pf <- rbind(subset(df, signif),
    subset(df, ord %in% ord.nonsignif))
  
  ord <- order(pf$ord)
  pf <- pf[ord, ]
  
  ### plotting settings
  reverselog_trans <- function(base = exp(1)) 
  {
    trans <- function(x) -log(x, base)
    inv <- function(x) base^(-x)
    scales::trans_new(paste0("reverselog-", format(base)), trans, inv, 
      log_breaks(base = base), 
      domain = c(1e-100, Inf))
  }
  
  xbreaks <- pf$ord
  xlables <- pf$SNP
  
  p <- switch(pval,
    "pval" = ggplot(pf, aes(ord, pSNP)) + geom_point() + 
      geom_segment(aes(x = ord, xend = ord, y = 1, yend = pSNP)) + 
      geom_hline(yintercept = alpha/N),
    "qval" = ggplot(pf, aes(ord, pSNP)) + geom_point() + 
      geom_segment(aes(x = ord, xend = ord, y = 1, yend = pSNP)) + 
      geom_hline(yintercept = alpha/N),
      stop("switch error (2) in `plot.solarAssoc`"))
  
  p <- p + scale_y_continuous(trans = reverselog_trans(10)) + 
    scale_x_continuous(breaks = xbreaks, labels = xlables) + 
    coord_flip()
  
  return(p)
}


