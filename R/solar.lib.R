
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
  
  df <- rename(df, renames)
  
  # ped  
  ped.cols <- as.character(renames)
  ped <- subset(df, select = ped.cols)
  
  # phen
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
  cmd <- c("load pedigree dat.ped", "load phenotypes dat.phe")
  ret <- solar(cmd, dir, result = TRUE)
  
  # check solar has completed the job
  stopifnot(file.exists(file.path(dir, "phi2.gz")))
  
  return(invisible())
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
