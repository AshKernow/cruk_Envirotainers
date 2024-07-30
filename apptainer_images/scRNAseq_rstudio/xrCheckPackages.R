#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidyverse))

message("Checking packages...")

pkgList <- read_lines("scRNAseqPackages.txt") %>% str_subset("^$", negate = TRUE)

fail <- pkgList

for(pkg in pkgList){
  check <- suppressPackageStartupMessages(require(pkg, character.only = TRUE, quietly = TRUE))
  if(check){
    fail <- fail %>% setdiff(pkg)
  }
}

if(length(fail) > 0){
  stop(paste("The following packages are not installed:", paste(fail, collapse = ", ")))
} else {
  message("All packages are installed.")
}
