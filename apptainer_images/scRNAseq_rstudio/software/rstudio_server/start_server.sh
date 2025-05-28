#!/bin/bash

projDir=/mnt/scratchc/bioinformatics/sawle01/Scripts/cruk_Envirotainers/apptainer_images/scRNAseq_rstudio
rsDir=${projDir}/software/rstudio_server

SBATCH=${rsDir}/rstudio-server.sbatch
IMAGE_DIR=${rsDir}
export RSTUDIO_WORK_DIR=~/.rstudio-server-cri

# Make the local working dir
if [ ! -d "$RSTUDIO_WORK_DIR"/.config ]
then
    mkdir -p "$RSTUDIO_WORK_DIR"/.config
fi

# Catch block to trigger on SIGINT or TERM EXIT
cleanup() {
    local JOBNO=$1
    echo "Killing slurm job $JOBNO"
    scancel $JOBNO
    exit
}

ARGS="$@"

rsImage=`ls ${IMAGE_DIR}/*.sif`
export RSTUDIO_SERVER_IMAGE="$rsImage"
RES=$(sbatch --output=$RSTUDIO_WORK_DIR/rstudio-server-out.%j --error=$RSTUDIO_WORK_DIR/rstudio-server-err.%j $ARGS $SBATCH)
JOBNO=${RES##* }

# Wait for job to be scheduled
echo -e "Waiting for job $JOBNO to start"
sleep 5s

while true
do
    sleep 1s
    STATUS=$(squeue -j $JOBNO -t PD,R -h -o %t)
    if [ "$STATUS" = "R" ]
    then
        break
    elif [ "$STATUS" != "PD" ]
    then
        echo "Job neither running nor pending, aborting"
        cleanup $JOBNO
        exit 1
    fi
done
echo "Job $JOBNO started"
trap "cleanup $JOBNO" ERR EXIT SIGINT SIGTERM KILL
tail -n 50 -f $RSTUDIO_WORK_DIR/rstudio-server-err."$JOBNO"
