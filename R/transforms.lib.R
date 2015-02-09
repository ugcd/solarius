
#---------------
# Configure functions
#---------------

#' @export
availableTransforms <- function() c("none", "inormal", "log", "out")

#---------------
# Transform functions
#---------------

#' @export
transformData <- function(transforms, data, ...)
{
  ### arg
  stopifnot(!missing(transforms))
  stopifnot(!missing(data))
  
  stopifnot(class(transforms) == "character")
  stopifnot(all(transforms %in% availableTransforms()))
  stopifnot(!is.null(names(transforms)))
  
  traits <- names(transforms)
  stopifnot(length(traits) == length(transforms))
  stopifnot(all(traits %in% colnames(data)))
  
  for(i in 1:length(transforms)) {
    var <- traits[i]
    tr <- transforms[i]
    
    x <- data[, var]    
    xt <- transformTrait(x, tr, ...)
    
    vart <- paste0("tr_", var)
    data[, vart] <- xt
  }
  
  return(data)
}

#' @export
transformTrait <- function(x, transform, ...)
{
  ### arg
  stopifnot(!missing(x))
  stopifnot(!missing(transform))  
  
  stopifnot(class(transform) == "character")
  stopifnot(length(transform) == 1)
  stopifnot(transform %in% availableTransforms())
  
  stopifnot(class(x) %in% c("integer", "numeric"))
  
  res <- switch(transform,
    "none" = list(x = x),
    "log" = list(x = transform_trait_log(x, ...)),
    "inormal" = list(x = transform_trait_inormal(x, ...)),
    "out" = list(x = transform_trait_out(x, ...)),
    stop("error in switch (unknown transform)"))

  xt <- res$x

  return(xt)
}

transform_trait_log <- function(x, log.base, log.intercept)
{
  stopifnot(!missing(x))

  # process `log.intercept`
  if(missing(log.intercept)) {
    x.min <- min(x, na.rm = TRUE)
    if(x.min <= 0) {
      x.min <- min(x, na.rm = TRUE)
      x <- x - x.min + 0.1
    }
  } else {
    x <- x - log.intercept

    x.min <- min(x, na.rm = TRUE)
    stopifnot(x.min > 0)
  }
  
  if(missing(log.base)) {
    xt <- log(x)
  } else {
    xt <- log(x, log.base)
  }

  return(xt)
}  
  
# test data: x <- c(NA, 10:1, NA)
transform_trait_inormal <- function(x, mean = 0, sd = 1)
{
  stopifnot(!missing(x))
  
  df0 <- data.frame(sample = 1:length(x), x = x) # data.frame with NA
  n0 <- nrow(df0)
  
  df <- subset(df0, !is.na(x)) # data.frame with NA removed

  df <- df[order(df$x), ]

  n <- nrow(df)
  df$y <- qnorm((1:n) / (n + 1), mean = mean, sd = sd)

  of <- join(df0, df[, c("sample", "y")], by = "sample") # join input and output data.frames
  of <- of[with(of, order(sample)), ]
  
  ### duplicate values
  of <- arrange(ddply(of, .(x), mutate, y = median(y,na.rm=TRUE)),sample)
  
  return(of$y)
}

transform_trait_out <- function(x, threshold = 4)
{
    repeat {
        sd.pre <- sd(x,na.rm=TRUE)
        mean.pre <- mean(x,na.rm=TRUE)
        
        x[x > (mean.pre + threshold * sd.pre)] <- NA
        x[x < (mean.pre - threshold * sd.pre)] <- NA
        
        sd.post <- sd(x,na.rm=T)
        if (sd.pre == sd.post) break
    }
    return(x)
}
