#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidyverse))

message("Checking packages...")

pkgList <- read_lines("scRNAseqPackages.txt") %>% str_subset("^$", negate = TRUE)

fail <- pkgList

for(pkg in pkgList){
  # Load each package in a fresh R process so packages can't interfere with
  # each other (e.g. leiden initialising Python before singleCellTK)
  check <- system2("Rscript",
                   c("-e", shQuote(sprintf("suppressPackageStartupMessages(library(%s))", pkg))),
                   stdout = FALSE, stderr = FALSE) == 0
  if(check){
    fail <- fail %>% setdiff(pkg)
  }
}

if(length(fail) > 0){
  stop(paste("The following packages are not installed:", paste(fail, collapse = ", ")))
} else {
  message("All packages are installed.")
}
