#' Run multivariate analysis and report results.
#'
#' @export
solarMultivar <- function(formula, data, traits, covlist = "1",
  ...,
  verbose = 0) 
{
  mc <- match.call()
  
  ### Step 1: parse arguments
  if(!missing(formula)) {
    formula.str <- as.character(formula)

    traits <- formula.str[2]
    traits <- strsplit(traits, "\\+")[[1]]
    traits <- gsub(" ", "", traits)
    
    formula.polygenic <- formula
    
    traits.polygenic <- traits
    covlist.polygenic <- as.character(NA)    
  } else {
    stopifnot(!missing(traits))
    
    traits.polygenic <- traits
    
    if(length(covlist) == 1) {
      formula.polygenic <-  paste(paste(traits, collapse = "+"), "~", 
      paste(covlist, collapse = "+"))

      covlist.polygenic <- llply(1:length(traits), function(i) covlist)
      formula.polygenic <- as.formula(formula.polygenic)
    } else {
      stopifnot(length(covlist) == length(traits))
      
      covlist.polygenic <- covlist
      
      cov.polygenic <- llply(1:length(covlist), function(i) {
        cov <- covlist[[i]]
        cov <- cov[!(cov %in% c("1", ""))]
        
        paste0(cov, "(", traits[i], ")")
      })
      cov.polygenic <- unlist(cov.polygenic)

      if(length(cov.polygenic) == 0) {
        cov.polygenic <- "1"
      }

      formula.polygenic <-  paste(paste(traits, collapse = " + "), "~", 
      paste(cov.polygenic, collapse = " + "))

      formula.polygenic <- as.formula(formula.polygenic)
    }
  }
  
  stopifnot(length(traits.polygenic) == 2)
  
  ### Step 2: polygenic
  if(verbose) {
    cat(" * run polygenic with formula:\n")
    print(formula.polygenic)
  }  
  
  model <- solarPolygenic(formula.polygenic, data, ..., verbose = verbose)

  ### Step 3: loop over traits to construct `data2`
  traits <- traits.polygenic
  covlist <- unique(unlist(covlist.polygenic))

  # fix classes of some covariates: from `character` to `factor`
  ind.covlist <- laply(covlist, function(x) which(names(data) == x))
  classes.covlist <- laply(data[, ind.covlist], class)
  stopifnot(all(classes.covlist %in% c("numeric", "integer", "character", "factor")))

  ind.covlist.character <- ind.covlist[classes.covlist == "character"]
  for(i in ind.covlist.character) {
    data[, i] <- as.factor(data[, i])
  }

  classes.covlist <- laply(data[, covlist], class)
  stopifnot(all(classes.covlist %in% c("numeric", "integer", "factor")))


  out <- list()    

  for(i in 1:length(traits)) {
    t <- traits.polygenic[i]
    
    # response    
    tval <- data[, t]
    tval.scaled <- scale(tval, center = TRUE, scale = TRUE)
    tval.scaled <- tval.scaled + attributes(tval.scaled)[["scaled:center"]]
    
    # data frame `dt`
    dt <- data.frame(tname = t, tnum = i - 1,
      trait = tval, strait = tval.scaled, 
      subset(data, select = covlist))
    
    covlist.t <- covlist.polygenic[[i]]
    for(f in covlist) {
      if(!(f %in% covlist.t)) {
        cl <- classes.covlist[f == covlist]
        if(cl %in% c("integer", "numeric")) {
          dt[, f] <- 0
        }
        else if(cl == "factor") {
          levels <- levels(dt[, f])
          n <- nrow(dt)
          dt[, f] <- factor(rep(1, n), levels = levels, labels = levels)
          
        } else {
          stop("erorr in classes.covlist")
        }
      }
    }      
    
    out[[t]] <- dt
  }

  data2 <- do.call(rbind, out)
  rownames(data2) <- NULL

  ### output
  out <- list(call = mc, 
    formula.polygenic = formula.polygenic, 
    traits.polygenic = traits.polygenic, covlist.polygenic = covlist.polygenic,
    model = model,
    data = data2)
  
  oldClass(out) <- c("solarMultivar")
  return(out)
}


#---------------------
# Class
#---------------------

#' S3 class solarMultivar.
#'
#' @name solarMultivar
#' @rdname solarMultivarClass
#'
#' @exportClass solarMultivar

#' @rdname solarMultivarClass
#' @export
print.solarMultivar <- function(x, ...)
{
  cat("\nCall: ")
  print(x$call)
  
  cat("\nPolygenic model\n")
  cat(" * traits:", paste(x$traits.polygenic, collapse = " / "), "\n")
  cat(" * covlist:", paste(laply(x$covlist.polygenic, function(y) paste(y, collapse = ", ")), collapse = " / "), "\n")
}
