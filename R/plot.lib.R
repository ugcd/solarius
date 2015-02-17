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
#' @importFrom ggplot2 qplot
#' @export histKinship2
histKinship2 <- function(kmat)
{
  p <- ggplot2::qplot(as.vector(kmat))
  print(p)
  
  return(invisible())
}
