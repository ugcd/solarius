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

#pedindex.out                                          
# 5 IBDID                 IBDID                       I
# 1 BLANK                 BLANK                       C
# 5 FATHER'S IBDID        FIBDID                      I
# 1 BLANK                 BLANK                       C
# 5 MOTHER'S IBDID        MIBDID                      I
# 1 BLANK                 BLANK                       C
# 1 SEX                   SEX                         I
# 1 BLANK                 BLANK                       C
# 3 MZTWIN                MZTWIN                      I
# 1 BLANK                 BLANK                       C
# 5 PEDIGREE NUMBER       PEDNO                       I
# 1 BLANK                 BLANK                       C
# 5 GENERATION NUMBER     GEN                         I
# 1 BLANK                 BLANK                       C
# 1 FAMILY ID             FAMID                       C
# 2 ID                    ID                          C
read_pedindex <- function(pedindex.out, ids.unique = TRUE)
{
  ### CDE
  pedindex.cde <- paste(tools::file_path_sans_ext(pedindex.out), "cde", sep = ".")

  cf <- read.fwf(pedindex.cde, skip = 1, widths = c(2, 22, 28, 2),
    stringsAsFactors = FALSE)
  names(cf) <- c("LEN", "FIELDNAME", "FIELD", "LETTER")
  cf <- mutate(cf,
    FIELD = gsub(" ", "", FIELD))
  
  # names & widths for `pedindex.out` file
  ind <- which(cf$FIELD != "BLANK")
  pnames <- cf$FIELD
  pwidths <- cf$LEN

  pf <- read.fwf(pedindex.out, widths = pwidths)

  pf <- pf[, ind]
  names(pf) <- pnames[ind]
  
  for(i in 1:ncol(pf)) {
    pf[, i] <- as.character(pf[, i])
  }  
  
  pf <- mutate(pf,
    ID = gsub(" ", "", ID))
  
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

kmat2phi2 <- function(kmat, dir, kin2.gz = "kin2.gz")
{
  kf <- kmat2kf(kmat)

  kf2phi2(kf, dir, kin2.gz = kin2.gz)  
}

#' @importFrom gdata write.fwf
kf2phi2 <- function(kf, dir, kin2.gz = "kin2.gz")
{
  pedindex.out <- file.path(dir, "pedindex.out")
  pf <- read_pedindex(pedindex.out)
  
  kf <- kf_match_pedindex(kf, pf)

  knames2 <- c("ID1", "ID2", "phi2")
  #knames2 <- c("IBDID1", "IBDID2", "phi2")  
  stopifnot(knames2 %in% names(kf))
  kf2 <- subset(kf, select = knames2)
  kf2 <- rename(kf2, c(ID1 = "id1", ID2 = "id2", phi2 = "matrix1"))
  #kf2 <- rename(kf2, c(IBDID1 = "id1", IBDID2 = "id2", phi2 = "matrix1"))
  
  knames <- c("IBDID1", "IBDID2", "phi2")
  stopifnot(knames %in% names(kf))
  kf <- subset(kf, select = knames)

  phi2.gz <- file.path(dir, kin2.gz)
  
  # @ http://helix.nih.gov/Documentation/solar-6.6.2-doc/08.chapter.html#phi2
  # - The coefficients should begin in the fourteenth character column, 
  #   or higher, counting the first character column as number one. 
  #   That is why `width = c(10, 10, 10)`.
  ret <- gdata::write.fwf(kf, gzfile(phi2.gz),
    rownames = FALSE, colnames = FALSE,
    sep = " ", width = c(10, 10, 10))

  #kf$d7 <- 1.0
  #kf <- mutate(kf,
  #  phi2 = sprintf("%.7f", phi2),
  #  d7 = sprintf("%.7f", d7)
  #)    
  
  #ret <- gdata::write.fwf(kf, gzfile(phi2.gz),
  #  rownames = FALSE, colnames = FALSE, justify = "right",
  #  sep = " ", width = c(5, 5, 10, 10))
  
  ### CSV format
  #ord <- with(kf2, order(as.integer(id1), as.integer(id2)))
  #kf2 <- kf2[ord, ]
  
  #ret <- write.table(kf2, gzfile(phi2.gz), quote = FALSE,
  #  row.names = FALSE, col.names = TRUE, sep = ",")
  
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
