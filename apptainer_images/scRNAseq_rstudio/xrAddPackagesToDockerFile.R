#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidyverse))

# Read in the Dockerfile
dat <- read_lines("Dockerfile")

# Remove R packages installation lines
end <- str_which(dat, "# Install R packages")
stt <- str_which(dat, "# End R packages")
dat1 <- dat[1:end]
dat2 <- dat[stt:length(dat)]

# Read in the R packages to install
rPackages <- read_lines("scRNAseqPackages.txt")

# Generate RUN lines to install the R packages
runLines <- str_c("RUN R --slave -e 'BiocManager::install(\"",
                   rPackages,
                   "\", ask = FALSE, lib=\"/usr/local/lib/R/site-library\")'")

# Add the R packages to the Dockerfile
dat <- c(dat1, runLines, dat2)

# Export the new Dockerfile
write_lines(dat, "Dockerfile")
