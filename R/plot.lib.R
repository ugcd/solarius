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
