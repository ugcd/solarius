#!/bin/bash

dirs=("pages/polygenic" "pages/bivariate" "pages/package")
wdir=$(pwd)

chunks=$wdir/scripts/chunks.Rmd

#pat="Rmd"
pat="data.Rmd"

for dir in ${dirs[@]} ; do
  echo " * dir: $dir"

  cd $dir

  files=$(ls | grep $pat)
  for file in $files ; do
    echo "  -- processing file: $file"
   
    basename="${file##*/}"
    filename="${basename%.*}"
    
    tmpfile="tmp.Rmd"
    #sed -n '1,5 p' $file > tmpfile
    head -n +5 $file > $tmpfile
    cat $chunks >> $tmpfile
    tail -n +6 $file >> $tmpfile

    
R -q --vanilla <<RSCRIPT
library(knitr)
knit("$tmpfile", "$filename.md")
RSCRIPT
    
    rm $tmpfile 
    
  done

  cd $wdir  
done


