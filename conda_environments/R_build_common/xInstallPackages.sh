#!/bin/bash
#
# Install each R package listed in a package list into a conda environment,
# one package at a time, writing a log per package and a summary log.
#
# Shared by the environment folders under conda_environments/ (ATAC, DNAseq,
# proteomics, RNAseq_analysis). Run it from the environment folder: the
# package list, the logs and the omnipathr-log cleanup are all relative to the
# current working directory.
#
# Configuration (environment variables):
#   ENV_NAME     conda environment to install into (required)
#   PKG_LIST     package list file         (default: PackagesToInstall.txt)
#   LOG_DIR      per-package log directory (default: AllPackageInstallationLogs)
#   SUMMARY_LOG  summary log file          (default: AllPackageInstallationSummary.log)

if [[ -z "${ENV_NAME}" ]]; then
    echo "ERROR: ENV_NAME must be set to the target conda environment." >&2
    exit 1
fi
PKG_LIST="${PKG_LIST:-PackagesToInstall.txt}"
logDir="${LOG_DIR:-AllPackageInstallationLogs}"
summaryLog="${SUMMARY_LOG:-AllPackageInstallationSummary.log}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

packages=($(grep -v "^#" "${PKG_LIST}"))
numPackages=${#packages[@]}
mkdir -p "${logDir}"
for pkgNum in $(seq 0 $((numPackages - 1))); do
    pkg=${packages[$pkgNum]}
    printf -v numPad "%02d" ${pkgNum}
    # fix package name in case it is a github repo
    pkgNam=$(echo $pkg | sed 's@.*/@@')
    logFile="${logDir}/${numPad}_PackageInstallation_${pkgNam}.log"
    echo "Installing package: $pkg"
    echo "Installing package: $pkg" > ${logFile}
    # Don't let one failure abort the loop; failures are reported in the summary
    conda run -n "${ENV_NAME}" Rscript "${SCRIPT_DIR}/xrInstallPackage.R" $pkg >> ${logFile} 2>&1 || \
        echo "%% ${pkgNam}: FAILURE" >> ${logFile}
done

cat ${logDir}/*.log |
    grep "%%" |
    sed 's/%% //g' \
    > "${summaryLog}"

# Remove the directory created by "omnipathr"
rm -rf omnipathr-log
