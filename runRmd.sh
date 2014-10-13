#!/bin/bash

dirs=("pages/polygenic" "pages/bivariate")
wdir=$(pwd)

for dir in ${dirs[@]} ; do
  echo " * dir: $dir"

  cd $dir

  files=$(ls | grep Rmd)
  for file in $files ; do
    echo "  -- processing file: $file"
    
    R -q -e "library(knitr);knit('$file')"
  done

  cd $wdir  
done


