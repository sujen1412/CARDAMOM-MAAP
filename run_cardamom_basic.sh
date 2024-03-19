#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)
OUTPUTDIR="${PWD}/output"
INPUT_FILE=$(ls -d input/*)

mkdir -p ${OUTPUTDIR}

"${basedir}/BASH/CARDAMOM_COMPILE.sh"

echo "WRITING OUTPUT NC FILE"

"${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${INPUT_FILE}" "${basedir}/cbrfile.cbr" "${OUTPUTDIR}/output_file_basic.nc"
