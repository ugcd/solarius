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
  
