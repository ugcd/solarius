
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

  # proc  
  cmd.proc_def <- c(get_proc_write_globals(),
    get_proc_write_covariate())

  cmd.proc_call <- c("write_covariate",
    "write_globals")
  
  if(length(out$traits) == 1) {
    cmd.proc_def <- c(cmd.proc_def, get_proc_write_param_univar())
    cmd.proc_call <- c(cmd.proc_call, 
      paste("write_param_univar ", "\"", out$solar$model.filename, "\"", sep = ""))
  }
  
  # cmd
  cmd <- c(paste("trait", paste(out$traits, collapse = " ")),
    paste("covariate", paste(covlist2, collapse = " ")),
    out$polygenic.settings,
    paste("polygenic", out$polygenic.options))
  
  ### run solar    
  ret <- solar(c(cmd.proc_def, cmd, cmd.proc_call), dir, result = TRUE)
  
  ### read output files
  model.dir <- paste(out$traits, collapse = ".")  
  model.path <- file.path(dir, model.dir)
  
  files.model <- solarReadFiles(model.path)
  
  ### extract vars from output files
  out$cf <- extactCovariateFrame(dir, out)
  
  ### update `out`
  out$ret <- ret
  out$solar$cmd <- cmd
  out$solar$files <- list(model = files.model)
    
  return(out)
}


#----------------------------------
# Extract functions
#----------------------------------
extactCovariateFrame <- function(dir, out)
{
  vals <- scan(file.path(dir, "out.covariate"), character(), quiet = TRUE)
  stopifnot(vals[1] == "covariate")
  
  if(length(vals) == 1) {
    return(data.frame())
  }
  
  cov <- vals[-1]
  ncov <- length(cov)
  
  cf <- data.frame(covariate = cov)
  
  if(length(out$traits) == 1) {
    tab <- read.table(file.path(dir, "out.param.univar"), colClasses = c("character", "numeric"))
#       V1            V2
#1 loglike -2.108689e+02
#2     h2r  8.061621e-01
#3   h2rSE  1.100465e-01
#4      e2  1.938379e-01
#5    e2SE  1.100465e-01
#6    bage  4.591117e-04
#7  bageSE  1.483783e-02
#8    bsex -4.559509e-01
#9  bsexSE  3.125045e-01
    
    # Estimate of betas
    bnames <- paste("b", cov, sep = "")
    stopifnot(all(bnames %in% tab[, 1]))

    ind <- which(tab[, 1] %in% bnames)
    cf$Estimate <- tab[ind, 2]
    
    # SE of betas
    SEnames <- paste("b", cov, "SE", sep = "")
    stopifnot(all(SEnames %in% tab[, 1]))

    ind <- which(tab[, 1] %in% SEnames)
    cf$SE <- tab[ind, 2]
    
    # P-values of betas
    lines <- readLines(file.path(dir, "out.globals"))
  }  
  
  return(cf)
}

  
  
#----------------------------------
# Solar proc
#----------------------------------

get_proc_write_globals <- function() 
{
"proc write_globals {} {\
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

get_proc_write_covariate <- function() 
{
"proc write_covariate {} {\
\
 	set covariates [covariate]\
\
  ### write to file\
	set f [open \"out.covariate\" \"w\"]\
\
  puts $f \"covariate $covariates\"\
\
	close $f\
}\
"
}

get_proc_write_varcomp_univar <- function() 
{
"proc write_varcomp_univar {} {\
\
 	set covariates [covariate]\
\
  ### write to file\
	set f [open \"out.varcomp\" \"w\"]\
\
  puts $f \"covariate $covariates\"\
\
	close $f\
}\
"
}

# @ http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html#read_model
# @ see any null0.mod
get_proc_write_param_univar <- function()
{
"proc write_param_univar {model} {\
\
	set loglike [read_model $model loglike]\
	set h2r [read_model $model h2r]\
	set h2rSE [read_model $model h2r -se]\
\
	if {[if_parameter_exists c2]} {\
    set c2 [read_model $model c2]\
    set c2SE [read_model $model c2 -se]\
	}\
	set e2 [read_model $model e2]\
	set e2SE [read_model $model e2 -se]\
\
  ### write to file\
	set f [open \"out.param.univar\" \"w\"]\
\
  puts $f \"loglike $loglike\"\
  puts $f \"h2r $h2r\"\
  puts $f \"h2rSE $h2rSE\"\
\
	if {[if_parameter_exists c2]} {\
    puts $f \"c2 $c2\"\
    puts $f \"c2SE $c2SE\"\
	}\
  puts $f \"e2 $e2\"\
  puts $f \"e2SE $e2SE\"\
\
 	set cov [covariate]\
  set ncov [llength $cov]\
  for {set i 0} {$i < $ncov} {incr i} {\
  	set covi [lindex $cov $i]\
  	if {[if_parameter_exists b$covi]} {\
      set bi [read_model $model b$covi]\
      set biSE [read_model $model b$covi -se]\
      puts $f \"b$covi $bi\"\
      puts $f \"b${covi}SE $biSE\"\
     }\
  }\
\
	close $f\
}\
"
}
