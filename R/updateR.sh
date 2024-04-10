#!/bin/bash

mamba env update --file R.yaml
currDate=`date | sed 's/ /_/g'`
mamba env config vars set --name R CreationDate=${currDate}

