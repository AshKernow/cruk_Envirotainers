#!/bin/bash

# Activate the conda environment
condaBin=$(dirname $(dirname $(which conda)))/bin
source ${condaBin}/activate scRNAseq_R

# Run the installation script
./R_scripts/xrRunInstall.R