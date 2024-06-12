#!/bin/bash

mamba env update --file R.yaml
currDate=`date | sed 's/ /_/g'`
mamba env config vars set --name R CreationDate=${currDate}

# Log the current versions of all software

timeStamp=$(date +"%Y%m%d_%H%M%S")
logFile=version_logs/versions_${timeStamp}.log

echo `date` > ${logFile}
echo >> ${logFile}
conda list -n R >>  ${logFile}
    
