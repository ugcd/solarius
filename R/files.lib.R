#----------------------------------
# Phenotype files
#----------------------------------

#' Read plain-text table files phen and ped
#'
#' The function reads the phenotype and pedigree data in SOLAR format,
#' i.e. plain-text tables.
#'
#' @param phen.file
#'    A character, path to phen file.
#' @param sep.phen
#'    A character, the field separator in phen file.
#'    The default value is \code{","}.
#' @param ped.file
#'    (optional) A character, path to ped file.
#' @param sep.ped
#'    A character, the field separator in ped file.
#'    The default value is \code{","}.
#' @param header
#'    Logical, indicating whether the file contains 
#'    the names of the variables as its first line.
#'    The default value is TRUE.
#' @param stringsAsFactors
#'    logical, indicating whether character vectors to be converted to factors.
#'    The default value is FALSE.
#' @param id.unique
#'    logical, indicating whether the IDs of individuals must be unique.
#'    The default value is TRUE.
#' @param sex.optional
#'    logical, indicating whether the SEX field must be presented.
#'    The default value is TRUE if \code{ped.file} is specified,
#'    and it is FALSE otherwise.
#' @return
#'    A data frame of phenotype data merged from two phen and ped files (merged by ID filed).
#'
#' @export
readPhen <- function(phen.file, sep.phen = ",",
  ped.file, sep.ped = ",", 
  header = TRUE, stringsAsFactors = FALSE,
  id.unique = TRUE, sex.optional, ...)
{
  stopifnot(!missing(phen.file)) 
  stopifnot(file.exists(phen.file))
  
  if(missing(sex.optional)) {
    sex.optional <- ifelse(missing(ped.file), FALSE, TRUE)
  }
  
  stopifnot(header)
  stopifnot(!stringsAsFactors)
  
  stopifnot(id.unique)
  
  ### read `phen` file
  sep <- sep.phen
  dat1 <- read.table(phen.file, nrows = 1,
    sep = sep, header = header, stringsAsFactors = stringsAsFactors)
  new.names <- matchIdNames(names(dat1), sex.optional = sex.optional)
  old.names <- names(new.names)
  
  ind <- which(names(dat1) %in% old.names)
  colClasses <- rep(as.character(NA), ncol(dat1))
  colClasses[ind] <- "character"
  
  dat <- read.table(phen.file, colClasses = colClasses,
    sep = sep, header = header, stringsAsFactors = stringsAsFactors)
  
  dat <- rename(dat, new.names)
  
  if(id.unique) {
    stopifnot(!any(duplicated(dat$ID)))
  }  
  
  ### read `ped` if necessary
  if(!missing(ped.file)) {
    stopifnot(file.exists(ped.file))
  
    sep <- sep.ped  
    ped <- read.table(ped.file, colClasses = "character",
      sep = sep, header = header, stringsAsFactors = stringsAsFactors)
   
    new.names <- matchIdNames(names(ped))
    ped <- rename(ped, new.names)

    if(id.unique) {
      stopifnot(!any(duplicated(dat$ID)))
    }  
    
    # merge `dat` & `ped`
    stopifnot("ID" %in% new.names)
    new.names2 <- new.names[!new.names %in% c("ID")]
    
    ind <- which(names(dat) %in% new.names2)
    if(length(ind)) {
      dat <- dat[, -ind]
    }
      
    dat <- base::merge(dat, ped, by = "ID", all = TRUE)      
  }
  
  return(dat)
}

#----------------------------------
# Association
#----------------------------------

check_assoc_files_exist <- function(genocov.files, snplists.files, snpmap.files)
{
  # genocov.files
  if(!missing(genocov.files)) {
    status <- laply(genocov.files, file.exists)
    if(!all(status)) {
      stop("Error in `check_assoc_files_exist`: ", sum(!status), " `genocov.files` do not exist.")
    }

    status <- laply(genocov.files, function(x) file.info(x)$isdir)
    if(any(status)) {
      stop("Error in `check_assoc_files_exist`: ", sum(status), " `genocov.files` are directories.")
    }
  }
      
  # snplists.files
  if(!missing(snplists.files)) {
    status <- laply(snplists.files, file.exists)
    if(!all(status)) {
      stop("Error in `check_assoc_files_exist`: ", sum(!status), " `snplists.files` do not exist.")
    }

    status <- laply(snplists.files, function(x) file.info(x)$isdir)
    if(any(status)) {
      stop("Error in `check_assoc_files_exist`: ", sum(status), " `snplists.files` are directories.")
    }
  }

  # snpmap.files
  if(!missing(snpmap.files)) {
    status <- laply(snpmap.files, file.exists)
    if(!all(status)) {
      stop("Error in `check_assoc_files_exist`: ", sum(!status), " `snpmap.files` do not exist.")
    }

    status <- laply(snpmap.files, function(x) file.info(x)$isdir)
    if(any(status)) {
      stop("Error in `check_assoc_files_exist`: ", sum(status), " `snpmap.files` are directories.")
    }
  }  
  return(invisible())  
}
  
