#!/usr/bin/env Rscript

library(purrr)
library(stringr)

# Install the package but exit with error if the package install
# fails.

installPackage <- function(pkg) {
    message("Attempting to install package ", pkg)
    BiocManager::install(pkg, ask = FALSE)
    test <- require(pkg)
    status <- ifelse(test, "success", "fail")
    message("----------------------------------------\n")
    str_c(pkg, ": ", status)
}

# Read the list of packages from the file and loop through
packages <- read_lines("Packages.txt")

# Remove any that are already installed
pkgs <- setdiff(packages, rownames(installed.packages()))

# Loop through and install each package
map_chr(pkgs, installPackage)

# Install sceasy from Github
devtools::install_github("cellgeni/sceasy")
