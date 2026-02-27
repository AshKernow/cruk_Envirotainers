#!/bin/bash

# Activate the conda environment
condaBin=$(dirname $(dirname $(which conda)))/bin
source ${condaBin}/activate RNAseq

# Run the installation script
packages=($(grep -v "^#" PackagesToInstall.txt))
numPackages=${#packages[@]}
logDir="AllPackageInstallationLogs"
mkdir -p ${logDir}
for pkgNum in $(seq 0 $((numPackages-1))); do
    pkg=${packages[$pkgNum]}
    printf -v numPad "%02d" ${pkgNum}
    # fix pakage name in case it is a github repo
    pkgNam=$(echo $pkg | sed 's@.*/@@')
    logFile="${logDir}/${numPad}_PackageInstallation_${pkgNam}.log"
    echo "Installing package: $pkg"
    echo "Installing package: $pkg" > ${logFile}
    ./xrInstallPackage.R $pkg >> ${logFile} 2>&1
done

cat ${logDir}/*.log | 
    grep "%%" |
    sed 's/%% //g' \
    > AllPackageInstallationSummary.log

# Remove the directory created by "omnipathr"
 rm -rf omnipathr-log