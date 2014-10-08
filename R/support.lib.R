
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

  ped <- read.table(file.path(dat.dir, "simulated.ped"), header = TRUE, sep = ",")
  phen <- read.table(file.path(dat.dir, "simulated.phen"), header = TRUE, sep = ",")
  dat <- merge(ped, phen)
  
  return(dat)
}
