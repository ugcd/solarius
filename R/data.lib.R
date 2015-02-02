#----------------------------------
# Data loaders
#----------------------------------

#' Function loadMulticData.
#'
#' @export
loadMulticData <- function()
{
  dat.dir <- system.file("inst", "extdata", "solarOutput", package = "solarius")
  if(!file.exists(dat.dir)) {
    dat.dir <- system.file("extdata", "solarOutput", package = "solarius")
  }
  stopifnot(file.exists(dat.dir))
  
  dat <- readPhen(phen.file = file.path(dat.dir, "simulated.phen"), sep.phen = ",", 
    ped.file = file.path(dat.dir, "simulated.ped"), sep.ped = ",")
  
  return(dat)
}


