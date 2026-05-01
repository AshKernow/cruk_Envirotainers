#!/usr/bin/env Rscript
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager", repos = "https://cran.ma.imperial.ac.uk/")
}
if (!requireNamespace("qPLEXanalyzer", quietly = TRUE)) {
    BiocManager::install("qPLEXanalyzer")
}

