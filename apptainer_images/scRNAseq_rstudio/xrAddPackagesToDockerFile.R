#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidyverse))

# Read in the Dockerfile
dat <- read_lines("Dockerfile")

# Remove R packages installation lines
end <- str_which(dat, "# Install R packages")
dat <- dat[1:end]

# Read in the R packages to install
rPackages <- read_lines("scRNAseqPackages.txt")

# Generate RUN lines to install the R packages
runLines <- str_c("RUN R --slave -e 'BiocManager::install(\"",
                   rPackages,
                   "\", ask = FALSE, lib=\"/usr/local/lib/R/site-library\")'")

# Add the R packages to the Dockerfile
dat <- c(dat, runLines)

# Export the new Dockerfile
write_lines(dat, "Dockerfile2")