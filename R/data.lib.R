#----------------------------------
# Data loaders
#----------------------------------

package.file <- function(...)
{
  path <- system.file(...)
  if(!file.exists(path)) {
    path <- system.file("inst", ...)
  }
  stopifnot(file.exists(path))
  
  return(path)
}

#' Function loadMulticPhen.
#'
#' @export
loadMulticPhen <- function()
{
  dat.dir <- package.file("extdata", "solarOutput", package = "solarius")
  
  dat <- readPhen(phen.file = file.path(dat.dir, "simulated.phen"), sep.phen = ",", 
    ped.file = file.path(dat.dir, "simulated.ped"), sep.ped = ",")
  
  return(dat)
}


#' Function loadExamplesPhen.
#'
#' @export
loadExamplesPhen <- function(dat.dir)
{ 
  ### dir
  is.tmpdir <- missing(dat.dir)
  
  if(is.tmpdir) {
    dir <- tempfile(pattern = "loadExamplesPhen-")
    stopifnot(dir.create(dir))
  }
  
  ### run solar
  if(is.tmpdir) {
    ret <- solar("example", dir)
    dat.dir <- dir
  }
  
  ### read files
  dat <- readPhen(phen.file = file.path(dat.dir, "gaw10.phen"), sep.phen = ",", 
    ped.file = file.path(dat.dir, "gaw10.ped"), sep.ped = ",")
  
  ### clean
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
  }
  
  return(dat)
}


