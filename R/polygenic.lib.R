
#----------------------------------
# Polygenic functions
#----------------------------------

solar_polygenic <- function(dir, out)
{
  stopifnot(file.exists(dir))
  
  ### make `cmd`
  
  # fix `covlist`: term `1`
  # - it may be given in formula
  # - to be omitted in SOLAR
  covlist2 <- out$covlist
  # filter out term 1
  ind <-  grep("^1$", covlist2)
  if(length(ind) > 0) { 
    covlist2 <- covlist2[-ind] 
  }
  
  cmd.proc <- c(get_proc_write_globals())
  
  cmd <- c(paste("trait", paste(out$traits, collapse = " ")),
    paste("covariate", paste(covlist2, collapse = " ")),
    paste("polygenic", out$polygenic.options),
    "write_globals_bivar")
  
  ### run solar    
  ret <- solar(c(cmd.proc, cmd), dir, result = TRUE)
  
  ### read output files
  model.dir <- paste(out$traits, collapse = ".")  
  model.path <- file.path(dir, model.dir)
  
  files.model <- solarReadFiles(model.path)
  
  ### update `out`
  out$ret <- ret
  out$files <- list(model = files.model)
  out$cmd <- cmd
    
  return(out)
}

#----------------------------------
# Solar proc
#----------------------------------

get_proc_write_globals <- function() 
{
"proc write_globals_bivar {} {\
\
  global SOLAR_Individuals\
  global SOLAR_H2r_P\
  global SOLAR_Kurtosis\
  global SOLAR_Covlist_P\
  global SOLAR_Covlist_Chi\
  global SOLAR_RhoP\
	global SOLAR_RhoP_P\
  global SOLAR_RhoP_SE\
	global SOLAR_RhoP_OK\
\
  ### write to file\
	set f [open \"out.globals\" \"w\"]\
\
  puts $f \"SOLAR_Individuals $SOLAR_Individuals\"\
  puts $f \"SOLAR_H2r_P $SOLAR_H2r_P\"\
  puts $f \"SOLAR_Kurtosis $SOLAR_Kurtosis\"\
  puts $f \"SOLAR_Covlist_P $SOLAR_Covlist_P\"\
  puts $f \"SOLAR_Covlist_Chi $SOLAR_Covlist_Chi\"\
\
  # Phenotypic Correlation\
  puts $f \"SOLAR_RhoP $SOLAR_RhoP\"\
  puts $f \"SOLAR_RhoP_SE $SOLAR_RhoP_SE\"\
  puts $f \"SOLAR_RhoP_P $SOLAR_RhoP_P\"\
  puts $f \"SOLAR_RhoP_OK $SOLAR_RhoP_OK\"\
\
	close $f\
}\
"
}
