
#----------------------------------
# Main functions
#----------------------------------

#' Function df2solar
#'
#' The function (1) puts the data set \code{df}
#' in SOLAR format, (2) separates it into
#' two parts, pedigree and phenotypes,
#' and then (3) expots both data sets in 
#' the directory \code{dir}.
#' 
#' @export
df2solar <- function(df, dir)
{
  # match ID/SEX names
  renames <- match_id_names(names(df))
  
  # set ut `unrelated`
  unrelated <- ifelse(all(c("FA", "MO") %in% renames), FALSE, TRUE)
  
  # rename
  df <- rename(df, renames)
  
  # ped  
  ped.cols <- as.character(renames)
  ped <- subset(df, select = ped.cols)
  
  # phen
  # - remove `ID` column
  ind.ID <- which(ped.cols == "ID")
  stopifnot(length(ind.ID) == 1)
  ped.cols2 <- ped.cols[-ind.ID]
  ind <- which(names(df) %in% ped.cols2)
  phen <- df[, -ind]
  
  # create dir
  set_dir(dir)
  
  # write tables  
  write.table(ped, file.path(dir, "dat.ped"),
    row.names = FALSE, sep = ",", quote = FALSE, na = "")

  write.table(phen, file.path(dir, "dat.phe"),
    row.names = FALSE, sep = ",", quote = FALSE, na = "")

  # run solar & load ped/phen
  cmd.ped <- "load pedigree dat.ped"
  if(unrelated) {
    cmd.ped <- paste(cmd.ped, "-founders")
  }
  cmd <- c(cmd.ped, "load phenotypes dat.phe")
  ret <- solar(cmd, dir, result = TRUE)
  
  # check solar has completed the job
  stopifnot(file.exists(file.path(dir, "phi2.gz")))
  
  return(invisible())
}


#' Function solarKinship
#'
#' The function (1) puts the data set \code{df}
#' in SOLAR format, (2) separates it into
#' two parts, pedigree and phenotypes,
#' and then (3) expots both data sets in 
#' the directory \code{dir},
#' (4) read the specific `phi2.gz` file,
#' where the kinship coefficients multiplied 
#' by 2 are stored by SOLAR.
#' 
#' @note
#' IDs in \code{df} are assumed to be not duplicated. 
#'
#' @export
solarKinship <- function(df, dir, ...)
{
  df2solar(df, dir, ...)
  
  # file names
  phi2.gz <- file.path(dir, "phi2.gz")
  pedindex.out <- file.path(dir, "pedindex.out")

  #### pedindex frame
  pf <- read.fwf(pedindex.out, widths = c(6, 6, 6, 2, 4, 6, 6, 15))
  names(pf) <- c("IBDID", "FIBDID", "MIBDID", "SEX", "MZTWIN", "PEDNO",
    "GEN", "ID")
  
  ### data frame with `phi2`
  kf <- read.table(gzfile(phi2.gz))
  names(kf) <- c("IBDID1", "IBDID2", "phi2", " delta7")
#> head(kf)
#  IBDID1 IBDID2      phi2  delta7
#1      1      1 0.1560492  0.2574
#2      1      1 1.0000000  1.0000
#3      2      2 1.0000000  1.0000
#4      3      3 1.0000000  1.0000

  # get rid of first two lines, which are duplicated
  if(with(kf, IBDID1[1] == IBDID2[1] & IBDID1[2] == IBDID2[2])) {
    kf <- kf[-1, ]
  }
  
  # check `phi2`
  N.diag <- with(kf, sum(IBDID1 == IBDID2))
  stopifnot(N == N.diag)
  


}

#----------------------------------
# Support functions
#----------------------------------

#' Function solar.
#'
#' @export
solar <- function(cmd, dir = "solar", result = TRUE,
  ignore.stdout = TRUE, ignore.stderr = FALSE, ...) 
{
  stopifnot(!missing(dir))
  
  cmd <- c(cmd, "quit")

  wd <- getwd()
  setwd(dir)
  
  if(result) {
    ignore.stdout <- FALSE
    ignore.stderr <- FALSE
  }
  
  res <- try({
    system("solar", input = cmd, intern = result, 
      ignore.stdout = ignore.stdout, ignore.stderr = ignore.stderr)
  })

  setwd(wd)

  if(result) { 
    return(res) 
  }
  else { 
    return(invisible()) 
  }
}

set_dir <- function(dir)
{
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  
  return(invisible())
}
