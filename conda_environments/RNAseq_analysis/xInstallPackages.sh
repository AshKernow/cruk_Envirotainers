#!/bin/bash

# Run the installation script
# ENV_NAME, PKG_LIST, LOG_DIR and SUMMARY_LOG can be overridden via the
# environment to target a different conda environment/package list (e.g.
# the RNAseq_R4.6 build), while defaulting to today's RNAseq_R behaviour.
ENV_NAME="${ENV_NAME:-RNAseq_R}"
PKG_LIST="${PKG_LIST:-PackagesToInstall.txt}"
logDir="${LOG_DIR:-AllPackageInstallationLogs}"
summaryLog="${SUMMARY_LOG:-AllPackageInstallationSummary.log}"

packages=($(grep -v "^#" "${PKG_LIST}"))
numPackages=${#packages[@]}
mkdir -p ${logDir}
for pkgNum in $(seq 0 $((numPackages - 1))); do
    pkg=${packages[$pkgNum]}
    printf -v numPad "%02d" ${pkgNum}
    # fix pakage name in case it is a github repo
    pkgNam=$(echo $pkg | sed 's@.*/@@')
    logFile="${logDir}/${numPad}_PackageInstallation_${pkgNam}.log"
    echo "Installing package: $pkg"
    echo "Installing package: $pkg" > ${logFile}
	conda run -n "${ENV_NAME}" Rscript xrInstallPackage.R $pkg >> ${logFile} 2>&1
done

cat ${logDir}/*.log |
    grep "%%" |
    sed 's/%% //g' \
    > "${summaryLog}"

# Remove the directory created by "omnipathr"
 rm -rf omnipathr-log