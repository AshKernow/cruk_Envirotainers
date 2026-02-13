#!/bin/bash

condaBin=/mnt/scratchc/bioinformatics/sawle01/software/miniforge3/bin
#condaBin=/home/sawle01/miniforge3/bin
CondaEnvName=proteomics
source ${condaBin}/activate ${CondaEnvName} 
# check if the conda environment is activated
if [ $? -ne 0 ]; then
    echo "Error: Failed to activate conda environment ${CondaEnvName}"
    exit 1
fi

# Install BiocManager if not already installed
Rscript -e "if (!requireNamespace('BiocManager', quietly=TRUE)) install.packages('BiocManager', repos='https://cloud.r-project.org/')"
# Install Bioconductor packages
Rscript -e "BiocManager::install(c('qPLEXanalyzer'), ask=FALSE, update=TRUE)"
