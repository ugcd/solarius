#----------------------------------
# Pedigree plots
#----------------------------------

#' @export
plotPed <- function(data, ped)
{
  # checks
  stopifnot(!missing(data))
  stopifnot(class(data) == "data.frame")
  stopifnot(!missing(ped))
  
  stopifnot(require(kinship2))
  
  renames <- match_id_names(names(data))
  data <- rename(data, renames)
  stopifnot(all(c("ID", "FA", "MO", "SEX", "FAMID") %in% names(data)))
  
  peds <- unique(data$FAMID)
  
  # filter by `ped`
  ped <- switch(class(ped),
    "integer" = peds[ped],
    "numeric" = peds[ped],
    "character" = ped,
    stop("switch error"))
  stopifnot(ped %in% peds)  
  
  ### create `df`
  df <- subset(data, FAMID == ped)
  
  ### filter `df`
  ids <- df$ID
  df <- within(df, {
    ind <- !(FA %in% ids)
    FA[ind] <- ""
    MO[ind] <- ""
    
    ind <- !(MO %in% ids)
    FA[ind] <- ""
    MO[ind] <- ""
  })
  
  # make `pedigree` object
  ped <- with(df, 
    pedigree(id = ID, dadid = FA, momid = MO, sex = SEX, famid = FAMID))  

  plot(ped[1])
}

#----------------------------------
# Association plots
#----------------------------------

#' @export
ManhattanPlot <- function(A)
{
  require(qqman)
  
  stopifnot(all(c("chr", "pSNP", "pos") %in% names(A$snpf)))
  
  df <- as.data.frame(A$snpf)

  #dt <- A$snpf[!is.na(chr) & !is.na(pSNP) & !is.na(pos)]
  #dt <- rename(dt, c(chr = "CHR", pos = "BP", pSNP = "P"))
  #dt <- mutate(dt, CHR = as.integer(CHR))

  num.na <- with(df, sum(is.na(chr) | is.na(pSNP) | is.na(pos)))
  num.snps <- nrow(df)
  
  #print(num.na)
  
  df <- subset(df, !is.na(chr) & !is.na(pSNP) & !is.na(pos))
  df <- rename(df, c(chr = "CHR", pos = "BP", pSNP = "P"))
  df <- mutate(df, CHR = as.integer(CHR))
    
  manhattan(df, suggestiveline = -log10(0.05/num.snps), genomewideline = -log10(5e-08))
}

#' @export
qqPlot <- function(A)
{
require(qqman)
dataP <- as.data.frame(A$snpf)
dataP <- dataP[,c("SNP", "pSNP", "pos", "chr")]
names(dataP)[2] <- "P"
names(dataP)[3] <- "BP"
dataP$CHR <- as.numeric(dataP$chr)

pos <- which(is.na(dataP$CHR))
if(length(pos)) {
  dataPP<- dataP[-pos,]
} else {
  dataPP<- dataP
}

qq(dataPP$P)
}

#----------------------------------
# Plot Kinship2
#----------------------------------

#' Function plotKinship2 
#'
#' @export plotKinship2 
plotKinship2 <- function(x, y = "image")
{
  switch(y,
    "image" = imageKinship2(x),
    "hist" = histKinship2(x),
    stop("switch error in `plotKinship2`"))
}

#' Function imageKinship2 
#'
#' @importFrom Matrix Matrix
#' @importFrom Matrix image
#' @export imageKinship2
imageKinship2 <- function(kmat)
{ 
  p <- Matrix::image(Matrix::Matrix(kmat))
  print(p)
  
  return(invisible())
}

#' Function histKinship2 
#'
#' @export histKinship2
histKinship2 <- function(kmat)
{
  stopifnot(require(ggplot2))
  
  df <- data.frame(kin = as.vector(kmat))
  
  ggplot(df, aes(kin)) + geom_histogram() + 
    labs(x = "") +
    theme_bw()
}

#----------------------
# Plot polygenic model
#----------------------

#' @export
plotRes <- function(x, conf = 0.90, 
  labels = FALSE, text.size = 4, ...)
{
  stopifnot(require(ggplot2))
  
  # var
  r <- residuals(x)
  yh <- residuals(x, trait = TRUE)
  labs <- names(r)
  
  # sd  
  r.sd <- sd(r, na.rm = TRUE)
  ind <- which(!(r > 3*r.sd | r < -3*r.sd)) # residuals inside [-3 sd; 3 sd]
  labs[ind] <- ""
  
  # data for plotting
  ord <- order(yh)
  df <- data.frame(ord = ord, yh = yh[ord], r = r[ord], label = labs[ord])
  
  # plot
  p <- ggplot(df, aes(x = ord, y = r)) + geom_point() +
    geom_hline(yintercept = 0) +
    geom_hline(yintercept = -3*r.sd, linetype = "dashed") + 
    geom_hline(yintercept = 3*r.sd, linetype = "dashed") +
    geom_smooth(method = "loess", se = FALSE) + #, se = TRUE, level = conf)
    labs(title = "Residuals",  
      x = "Trait order", y = "Residuals")
  
  if(labels) {
    p <- p + geom_text( aes(label = label), size = text.size) # hjust = 0, vjust = 0
  }
  
  # print
  if(labels) {
    labs <- with(df, label[label != ""])
    if(length(labs) > 0) {
      cat(" * Sample(s) outside the 3*sd interval: ", 
        paste(labs, collapse = ", "), "\n", sep = "")
    } else {
      cat(" * All sampes are within the 3*sd interval\n", sep = "")
    }
  }
  
  # return
  return(p)
}
 
 
# source: http://stackoverflow.com/a/27191036/551589
# alternatives: 
#  -- qqnorm(res); qqline(res)
#  -- cars::qqPlot(res, id.method = "identify")
#' @export
plotResQQ <- function(x, distribution = "norm", ..., line.estimate = NULL, 
  conf = 0.90, 
  labels = FALSE, text.size = 4)
{
  stopifnot(require(ggplot2))
  
  ### var
  r <- residuals(x)
  labs <- names(r)
  
  q.function <- eval(parse(text = paste0("q", distribution)))
  d.function <- eval(parse(text = paste0("d", distribution)))

  r <- na.omit(r)
  ord <- order(r)
  n <- length(r)
  P <- ppoints(length(r))
  df <- data.frame(ord.r = r[ord], z = q.function(P, ...))

  if(is.null(line.estimate)) {
    Q.r <- quantile(df$ord.r, c(0.25, 0.75))
    Q.z <- q.function(c(0.25, 0.75), ...)
    b <- diff(Q.r)/diff(Q.z)
    coef <- c(Q.r[1] - b * Q.z[1], b)
  } else {
    coef <- coef(line.estimate(ord.r ~ z))
  }

  zz <- qnorm(1 - (1 - conf)/2)
  SE <- (coef[2]/d.function(df$z)) * sqrt(P * (1 - P)/n)
  fit.value <- coef[1] + coef[2] * df$z
  df$upper <- fit.value + zz * SE
  df$lower <- fit.value - zz * SE

  df$label <- ifelse(df$ord.r > df$upper | df$ord.r < df$lower, labs[ord], "")

  p <- ggplot(df, aes(x=z, y=ord.r)) + geom_point() + 
    geom_abline(intercept = coef[1], slope = coef[2]) + 
    geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2) +
    labs(title = "Q-Q plot", 
      x = paste0("Theoretical quantiles (", distribution, " distribution)"),
      y = "Sample quantiles")

  if(labels) {
    p <- p + geom_text( aes(label = label), size = text.size) # hjust = 0, vjust = 0
  }
  
  ### print
  if(labels) {
    labs <- with(df, label[label != ""])
    if(length(labs) > 0) {
      cat(" * Sample(s) outside the confidence interval (", conf, "): ", 
        paste(labs, collapse = ", "), "\n", sep = "")
    } else {
      cat(" * All sampes are within the confidence interval (", conf, ")\n", sep = "")
    }
  }
  
  return(p)
}
