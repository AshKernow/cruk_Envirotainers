#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidyverse))

# Get list of expected packages from R.yaml

pkgList <- yaml::yaml.load_file("R.yaml")$dependencies

pks <- str_remove(pkgList, ".*-") %>%
    str_subset("certificates", negate = TRUE)

# Check if a package is installed

insPackages <- installed.packages() %>% rownames() %>% str_to_lower()
checkInstalled <- function(pkg, insList = insPackages) {
    if (!pkg %in% insList) {
        print(paste0(pkg, " is not installed"))
    }
}


# Check if all packages are installed

walk(pks, checkInstalled)
