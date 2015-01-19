
#----------------------------------
# Main functions
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

#' Function df2solar
#'
#' The function (1) puts the data set \code{df}
#' in SOLAR format, (2) separates it into
#' two parts, pedigree and phenotypes,
#' and then (3) expots both data sets in 
#' the directory \code{dir}.
#' 
#' @export
df2solar <- function(df, dir, kinship, kin2.gz = "kin2.gz")
{
  # match ID/SEX names
  renames <- match_id_names(names(df))
  
  # set up `unrelated`
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
  
  # kinship
  if(!missing(kinship)) {
    kmat <- 2*kinship
    kmat2phi2(kmat, dir, kin2.gz = kin2.gz)
    
    cmd <- paste("matcrc ", kin2.gz)
    ret <- solar(cmd, dir, result = TRUE)  
  }
  
  # check solar has completed the job
  stopifnot(file.exists(file.path(dir, "phi2.gz")))
  
  return(invisible())
}

#' Function snpdata2solar.
#'
#' The function (1) exports the data set of genotypes stored 
#' in \code{mat} itto SOLAR files, (2) runs solar command `snp load solar.gen` 
#' to check the data is loaded ok; (3) if two output files were not created,
#' throws error.
#'
#' @export
snpdata2solar <- function(mat, dir)
{
  # parse arguments
  stopifnot(class(mat) == "matrix")

  stopifnot(!is.null(rownames(mat)))
  stopifnot(!is.null(colnames(mat)))
  
  stopifnot(file.exists(dir))

  ids <- rownames(mat)
  snpnames <- colnames(mat)
  
  # prepare `mat`
  mat <- cbind(ID = ids, mat)
  
  # write table
  write.table(mat, file.path(dir, "dat.snp"),
    row.names = FALSE, sep = ",", quote = FALSE, na = "")
  
  # run solar
  cmd <- c("snp load dat.snp", "snp covar -nohaplos", "snp unload")
  ret <- solar(cmd, dir, result = TRUE)  

  # check solar has completed the job
  stopifnot(file.exists(file.path(dir, "snp.genocov")))
  stopifnot(file.exists(file.path(dir, "snp.geno-list")))

  return(invisible())
}

#' Function snpcovdata2solar.
#'
#' The function emulate the `snp load` SOLAR command.
#' Two output files are produced: `snp.genocov` and `snp.geno-list`.
#' The steps are the following: (1) add prefix `snp_` to SNP names;
#' (2) (optiona) compute stats on # genotyped individuals (columns `nGTypes`);
#' (3) write data and metadata into files.
#'
#' Example of `snp.genocov` file:
#'   id,nGTypes,snp_s1,snp_s2,...
#'   1,50,0,0,...
#'   2,50,0,0,...
#'
#' Example of `snp.geno-list` file:
#'  snp_s1
#'  snp_s2
#'  ...
#'
#' @export
snpcovdata2solar <- function(mat, out, dir, nGTypes = FALSE)
{
  # parse arguments
  stopifnot(class(mat) == "matrix")

  stopifnot(!is.null(rownames(mat)))
  stopifnot(!is.null(colnames(mat)))
  
  stopifnot(file.exists(dir))

  # slots in `out` argumnet
  genocov.files <- out$assoc$genocov.files
  stopifnot(length(genocov.files) == 1)

  genolist.file <- out$assoc$genolist.file
  stopifnot(length(genolist.file) == 1)
    
  # extract variabels
  ids <- rownames(mat)
  snpnames <- colnames(mat)

  # compute `ID` and `nGTypes` columns
  snpnames <- paste("snp", snpnames, sep = "_")
  if(nGTypes) {
    ngtypes <- apply(genocovdata, 1, function(x) sum(!is.na(x)))
  }
  
  # prepare `mat`
  colnames(mat) <- snpnames
  if(nGTypes) {
    mat <- cbind(ID = ids, nGTypes = ngtypes, mat)
  } else {
    mat <- cbind(ID = ids, mat)
  }
  
  # write table
  write.table(mat, file.path(dir, genocov.files),
    row.names = FALSE, sep = ",", quote = FALSE, na = "")

  write.table(snpnames, file.path(dir, genolist.file),
    col.names = FALSE, row.names = FALSE, sep = ",", quote = FALSE, na = "")
  
  return(invisible())
}

#----------------------------------
# Kinship functions
#----------------------------------

#' Function solarKinship2
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
solarKinship2 <- function(df, dir, ...)
{
  is.tmpdir <- missing(dir)
  if(is.tmpdir) {
    dir <- tempfile(pattern = "solarKinship2-")
  }
  
  df2solar(df, dir, ...)
  
  # file names
  phi2.gz <- file.path(dir, "phi2.gz")
  pedindex.out <- file.path(dir, "pedindex.out")

  #### pedindex frame
  pf <- read_pedindex(pedindex.out)
  N <- nrow(pf)

  ### data frame with `phi2`
  kf <- read_phi2_gz(phi2.gz)
  N.diag <- with(kf, sum(IBDID1 == IBDID2))
  stopifnot(N == N.diag)
    
  # create `index` 
  kf <- kf_match_pedindex(kf, pf)
  
  kf <- subset(kf, select = c("IBDID1", "IBDID2", "ID1", "ID2", "phi2"))
  kmat <- kf2kmat(kf)
  
  ###clean
  if(is.tmpdir) {
    unlink(dir, recursive = TRUE)
  }
  
  return(kmat)
}

kf2kmat <- function(kf)
{
  stopifnot(class(kf) == "data.frame")
  stopifnot(all(c("ID1", "ID2", "phi2") %in% names(kf)))
  
  ids <- unique(c(kf$ID1, kf$ID2))
  N <- length(ids)
  
  kmat <- matrix(0, nrow = N, ncol = N)
  rownames(kmat) <- ids
  colnames(kmat) <- ids
  
  for(i in 1:nrow(kf)) {
    kmat[kf$ID1[i], kf$ID2[i]] <- kf$phi2[i]
    kmat[kf$ID2[i], kf$ID1[i]] <- kf$phi2[i]
  }
  
  return(kmat)
}

kmat2kf <- function(kmat)
{
  stopifnot(class(kmat) == "matrix")

  stopifnot(nrow(kmat) == ncol(kmat))
  N <- nrow(kmat)

  # ids
  stopifnot(all(rownames(kmat) == colnames(kmat)))
  ids <- rownames(kmat)
  
  # create `kf`
  N.nonzero <- sum(kmat != 0)
  N.vec <- N + (N.nonzero - N) / 2 # matrix is symmetric with `N` diagonal elements
  
  ids1 <- rep(as.character(NA), N.vec)
  ids2 <- rep(as.character(NA), N.vec)
  vals <- rep(as.numeric(NA), N.vec)
  
  k <- 1
  for(i in 1:N) {
    for(j in i:N) {
      val <- kmat[i, j]
      if(val) {
        ids1[k] <- ids[j]
        ids2[k] <- ids[i]
        vals[k] <- val
        
        k <- k + 1
      }
    }
  }
  stopifnot(N.vec == k - 1)
  
  kf <- data.frame(ID1 = ids1, ID2 = ids2, phi2 = vals,
    stringsAsFactors = FALSE)
  
  return(kf)
}

kf_match_pedindex <- function(kf, pf)
{
  stopifnot(class(kf) == "data.frame")
  stopifnot(class(pf) == "data.frame")
  
  stopifnot(all(c("IBDID", "FIBDID", "MIBDID", "SEX", "MZTWIN", "PEDNO",
    "GEN", "ID") %in% names(pf)))
  
  if(!all(c("ID1", "ID2") %in% names(kf))) {
    stopifnot(all(c("IBDID1", "IBDID2") %in% names(kf)))

    ibdids.pf <- unique(pf$IBDID)
    ibdids.kf <- unique(c(kf$IBDID1, kf$IBDID2))
    stopifnot(all(ibdids.kf %in% ibdids.pf))
    stopifnot(all(ibdids.pf %in% ibdids.kf))  
    
    N <- nrow(pf)
    
    # add `index` column
    kf <- mutate(kf,
      index = paste(IBDID1, IBDID2, sep = "."))
  
    # match IBDID with ID for two indiced 1, 2 via `pf` (pedindex)
    mf1 <- join(data.frame(IBDID = kf$IBDID1, index = kf$index), subset(pf, select = c("IBDID", "ID")), by = "IBDID")
    mf2 <- join(data.frame(IBDID = kf$IBDID2, index = kf$index), subset(pf, select = c("IBDID", "ID")), by = "IBDID")
  
    # induce IDs in `kf` 
    kf <- join(kf, subset(rename(mf1, c(ID = "ID1")), select = c("ID1", "index")), by = "index")
    kf <- join(kf, subset(rename(mf2, c(ID = "ID2")), select = c("ID2", "index")), by = "index")
    
    # remove `index`
    ind <- which(names(kf) == "index")
    stopifnot(length(ind) == 1)
    kf <- kf[, -ind]
  }

  if(!all(c("IBDID1", "IBDID2") %in% names(kf))) {
    stopifnot(all(c("ID1", "ID2") %in% names(kf)))
    
    ids.pf <- unique(pf$ID)
    ids.kf <- unique(c(kf$ID1, kf$ID2))
    #print(ids.pf)
    #print(ids.kf)
    stopifnot(all(ids.kf %in% ids.pf))
    stopifnot(all(ids.pf %in% ids.kf))    
    
    N <- nrow(pf)
    
    # add `index` column
    kf <- mutate(kf,
      index = paste(ID1, ID2, sep = "."))
    stopifnot(!all(duplicated(kf$index)))
  
    # match ID with IBDID for two indiced 1, 2 via `pf` (pedindex)
    mf1 <- join(data.frame(ID = kf$ID1, index = kf$index), subset(pf, select = c("IBDID", "ID")), by = "ID")
    mf2 <- join(data.frame(ID = kf$ID2, index = kf$index), subset(pf, select = c("IBDID", "ID")), by = "ID")
  
    # induce IBDIDs in `kf` 
    kf <- join(kf, subset(rename(mf1, c(IBDID = "IBDID1")), select = c("IBDID1", "index")), by = "index")
    kf <- join(kf, subset(rename(mf2, c(IBDID = "IBDID2")), select = c("IBDID2", "index")), by = "index")
    
    # remove `index`
    ind <- which(names(kf) == "index")
    stopifnot(length(ind) == 1)
    kf <- kf[, -ind]
  }
  
  return(kf)
}

#----------------------------------
# Support functions
#----------------------------------

set_dir <- function(dir)
{
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  
  return(invisible())
}

#----------------------------------
# File formats
#----------------------------------

format_snpdata <-function(mat, snpformat)
{
  switch(snpformat,
    "012" = {
      apply(mat, 2, function(x) ifelse(is.na(x), as.character(NA), 
        ifelse(x == 0, "1/1", ifelse(x == 1, "1/2", ifelse(x == 2, "2/2", 
        as.character(NA))))))
    },
    stop(paste("error in `format_snpdata`; `snpformat`", snpformat, "is unknown")))
}











