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

read_pedindex <- function(pedindex.out, ids.unique = TRUE)
{
  pf <- read.fwf(pedindex.out, widths = c(6, 6, 6, 2, 4, 6, 6, 15))
  names(pf) <- c("IBDID", "FIBDID", "MIBDID", "SEX", "MZTWIN", "PEDNO",
    "GEN", "ID")
  
  for(i in 1:ncol(pf)) {
    pf[, i] <- as.character(pf[, i])
  }  
  
  if(ids.unique) {
    stopifnot(!all(duplicated(pf$ID)))
  }
  
  return(pf)
}

read_phi2_gz <- function(phi2.gz)
{
  kf <- read.table(gzfile(phi2.gz))
  names(kf) <- c("IBDID1", "IBDID2", "phi2", "delta7")
#> head(kf)
#  IBDID1 IBDID2      phi2  delta7
#1      1      1 0.1560492  0.2574
#2      1      1 1.0000000  1.0000
#3      2      2 1.0000000  1.0000
#4      3      3 1.0000000  1.0000

  # get rid of first two lines, which may be duplicated
  if(with(kf, IBDID1[1] == IBDID2[1] & IBDID1[2] == IBDID2[2])) {
    kf <- kf[-1, ]
  }
  
  return(kf)
}

kmat2phi2 <- function(kmat, dir)
{
  kf <- kmat2kf(kmat)

  kf2phi2(kf, dir)  
}

#' @importFrom gdata write.fwf
kf2phi2 <- function(kf, dir)
{
  pedindex.out <- file.path(dir, "pedindex.out")
  pf <- read_pedindex(pedindex.out)
  
  kf <- kf_match_pedindex(kf, pf)
  
  knames <- c("IBDID1", "IBDID2", "phi2")
  stopifnot(knames %in% names(kf))
  kf <- subset(kf, select = knames)
  
  # @ http://helix.nih.gov/Documentation/solar-6.6.2-doc/08.chapter.html#phi2
  # - The coefficients should begin in the fourteenth character column, 
  #   or higher, counting the first character column as number one. 
  #   That is why `width = c(10, 10, 10)`.
  phi2.gz <- file.path(dir, "kin2.gz")
  ret <- gdata::write.fwf(kf, gzfile(phi2.gz),
    rownames = FALSE, colnames = FALSE,
    sep = " ", width = c(10, 10, 10))
  
  return(invisible())
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
  # filter out interaction terms with `#`
  ind <-  grep("\\#", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  # filter out power terms with "^"
  ind <-  grep("\\^", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  
  # filter out covariates like `c("sex(trait1)", "age(trait2)")`
  covlist3 <- covlist2
  if(length(covlist2)) {
    ind <- grep("\\(", covlist2)
    if(length(ind)) {
      covlist3[ind] <- laply(strsplit(covlist3[ind], "\\("), function(x) x[1])
    }
  }
  
  stopifnot(all(covlist3 %in% dnames))
  
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
  
  ### option 1
  #out <- c("ID", "FAMID", "MO", "FA", "SEX")
  #out.names <- c(find_name("^id$|^ID$", fields),
  #  find_name("^famid$|^FAMID$", fields),
  #  find_name("^mo$|^MO$|^mother$|^MOTHER$", fields),
  #  find_name("^fa$|^FA$|^father$|^FATHER$", fields),
  #  find_name("^sex$|^SEX$", fields))
  #names(out) <- out.names

  ### option 2
  out <- c("ID")
  # ID field (obligatory)
  pat <- "^id$|^ID$"
  names <- grep(pat, fields, value = TRUE) 
  if(length(names) == 0) stop("ID name not found; grep pattern '", pat, "'")
  if(length(names) > 1)  stop("more than one ID names found (", paste(names, collapse = ", "), "); grep pattern '", pat, "'")
  out.names <- names
  # FAMID (optional)
  pat <- "^famid$|^FAMID$"
  names <- grep(pat, fields, value = TRUE) 
  if(length(names) > 1)  stop("more than one FAMID names found (", paste(names, collapse = ", "), "); grep pattern '", pat, "'")   
  if(length(names) == 1) {
    out <- c(out, "FAMID")
    out.names <- c(out.names, names)
  }
  # MO (optional)
  pat <- "^mo$|^MO$|^mother$|^MOTHER$"
  names <- grep(pat, fields, value = TRUE) 
  if(length(names) > 1)  stop("more than one MO names found (", paste(names, collapse = ", "), "); grep pattern '", pat, "'")   
  if(length(names) == 1) {
    out <- c(out, "MO")
    out.names <- c(out.names, names)
  }
  # FA (optional)
  pat <- "^fa$|^FA$|^father$|^FATHER$"
  names <- grep(pat, fields, value = TRUE) 
  if(length(names) > 1)  stop("more than one FA names found (", paste(names, collapse = ", "), "); grep pattern '", pat, "'")   
  if(length(names) == 1) {
    out <- c(out, "FA")
    out.names <- c(out.names, names)
  }    
  # SEX field (obligatory)
  pat <- "^sex$|^SEX$"
  names <- grep(pat, fields, value = TRUE) 
  if(length(names) == 0) stop("SEX name not found; grep pattern '", pat, "'")
  if(length(names) > 1)  stop("more than one SEX names found (", paste(names, collapse = ", "), "); grep pattern '", pat, "'")
  if(length(names) == 1) {
    out <- c(out, "SEX")
    out.names <- c(out.names, names)
  }
  
  names(out) <- out.names    
  
  return(out)
}
