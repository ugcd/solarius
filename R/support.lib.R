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

  ped <- read.table(file.path(dat.dir, "simulated.ped"), header = TRUE, sep = ",")
  phen <- read.table(file.path(dat.dir, "simulated.phen"), header = TRUE, sep = ",")
  dat <- merge(ped, phen)
  
  return(dat)
}


#----------------------------------
# Read/Write Files
#----------------------------------

#' @export
solarReadFiles <- function(dir)
{
  stopifnot(!missing(dir))
  stopifnot(file.exists(dir))

  filenames <- list.files(dir)    
  files <- list.files(dir, full.names = TRUE)

  stopifnot(length(files) > 0)

  out <- list()    
  for(i in 1:length(files)) {
    out[[filenames[i]]] <- readLines(files[i])
  }
  
  return(out)
}

#----------------------------------
# Checkers
#----------------------------------

check_var_names <- function(traits, covlist, dnames) {
  ### traits
  stopifnot(all(traits %in% dnames))
  
  ### covlist
  covlist2 <- covlist
  # filter out term 1
  ind <-  grep("^1$", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  # filter out interaction terms with `*`
  ind <-  grep("\\*", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  # filter out power terms with "^"
  ind <-  grep("\\^", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  stopifnot(all(covlist2 %in% dnames))
  
  return(invisible())
}

#' Function match_id_names
#
#' @examples inst/examples/example-fields.R
match_id_names <- function(fields)
{
  # `fields`: fields in data set
  # `names`: matched names
  
  find_name <- function(pat, fields) {
    names <- grep(pat, fields, value = TRUE)
    if(length(names) == 0) {
      stop("ID names not found; grep pattern '", pat, "'")
    }
    if(length(names) > 1) {
      stop("more than one ID names found (", paste(names, collapse = ", "), "); grep pattern '", pat, "'")
    }
    
    return(names)
  }
  
  out <- c("ID", "FAMID", "MO", "FA", "SEX")
  out.names <- c(find_name("^id$|^ID$", fields),
    find_name("^famid$|^FAMID$", fields),
    find_name("^mo$|^MO$|^mother$|^MOTHER$", fields),
    find_name("^fa$|^FA$|^father$|^FATHER$", fields),
    find_name("^sex$|^SEX$", fields))
  names(out) <- out.names

  return(out)
}
