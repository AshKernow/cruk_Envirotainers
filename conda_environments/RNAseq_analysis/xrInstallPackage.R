#!/usr/bin/env Rscript

pkg <- commandArgs(trailingOnly = TRUE)[1]
if( is.na(pkg) ) {
  stop("No package specified. Usage: Rscript xrInstallPackage.R <package_name>")
}

# First check if the package is already installed
checkPackage <- function(pack) {
    suppressPackageStartupMessages(
        require(pack, character.only=TRUE, quietly=TRUE)
    )
}
pkgNam <- gsub(".*/", "", pkg) # extract the package name in case it is a GitHub repo string
pkgInstalled <- checkPackage(pkgNam)

# Avoid Linux binary packages that may require newer glibc than available on host.
options(pkgType = "source")
Sys.setenv(R_PKGTYPE = "source")

# Next check if the package is to be installed from GitHub - it will have a "/" in the name
gitHub <- grepl("/", pkg)
# If not installed, attempt to install the package using BiocManager
if(!pkgInstalled) {
    message("Attempting to install package ", pkgNam)
    # if not GitHub, install using BiocManager
    if(!gitHub) {
        BiocManager::install(pkg, ask = FALSE) 
    } else {
        # if GitHub, try pak first, then fall back to remotes install from source.
        tryCatch({
            pak::pak(pkg)
        }, error = function(e) {
            warning("Failed to install ", pkg, " with pak: ", e$message)
            remotes::install_github(pkg, dependencies = TRUE, upgrade = "never")
        })
    }
    test <- checkPackage(pkgNam)
    status <- ifelse(test, "success", "FAILURE")
} else {
    status <- "already installed"
}

message("%% ", pkgNam, ": ", status)