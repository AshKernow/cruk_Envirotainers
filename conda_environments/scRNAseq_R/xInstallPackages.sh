#!/bin/bash

# Activate the conda environment
condaBin=/mnt/scratchc/bioinformatics/sawle01/software/miniforge3/bin
source ${condaBin}/activate scRNAseq_R

# Run the installation script
./R_scripts/xrRunInstall.R