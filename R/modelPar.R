
#------------------------------
# Main functions (out.globals)
#------------------------------

#' @export
modelPar <- function(mod, par, ...)
{
  switch(par,  
    "cores" = modelParCores(mod),
    "CPUtime" = modelParCPUtime(mod, ...),
    "NumBatches" = modelParNumBatches(mod),
    stop(paste0("switch for `par` value"))
  )
}

#' @export
modelParCPUtime <- function(mod, format = "sec", ...) 
{ 
  switch(class(mod)[1],
    "solarAssoc" = {
      t <- mod$assoc$tprofile$cputime.sec
      switch(format,
        "sec" = t,
        "POSIX" = format(.POSIXct(t, tz = "GMT"), "%H:%M:%S"),
        stop("swith error for `format`"))
    },
    stop("swith error for class of `mod`"))
}

#' @export
modelParCores <- function(mod) 
{ 
  switch(class(mod)[1],
    "solarAssoc" = mod$assoc$cores,
    stop("swith error for class of `mod`"))
}

#' @export
modelParNumBatches <- function(mod) 
{ 
  switch(class(mod)[1],
    "solarAssoc" = length(mod$assoc$solar$cmd),
    stop("swith error for class of `mod`"))
}














