#!/usr/bin/env Rscript
if (!requireNamespace("tidyverse", quietly = TRUE)) {
    install.packages("tidyverse", repos = "https://cran.ma.imperial.ac.uk/")
}
library(tidyverse)

# log file
timenow <- str_replace_all(as.character(Sys.time()), " ", "_") %>% 
    str_remove_all(":|\\.[0-9]+$")

filename <- str_c("PackageInstallation_", timenow, ".log")

con <- file(filename)
sink(con, append = TRUE)
sink(con, append = TRUE, type = "message")

# This will echo all input and not truncate 150+ character lines...
source("R_scripts/InstallPackages.R", echo = TRUE, max.deparse.length = 10000)

