#!/bin/bash
set -e

cran="https://cran.rstudio.com/src/contrib/"
if wget --spider $cran$1"_"$2.tar.gz 2>/dev/null; then
  wget $cran$1"_"$2.tar.gz
else
  wget $cran/Archive/$1/$1"_"$2.tar.gz
fi
R CMD INSTALL --clean --no-multiarch --without-keep.source --byte-compile --resave-data --compact-docs --no-demo $1"_"$2.tar.gz
rm $1"_"$2.tar.gz
