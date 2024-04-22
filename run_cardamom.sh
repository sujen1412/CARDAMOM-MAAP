#!/bin/bash

set -e

# shellcheck disable=SC1091
source /opt/conda/etc/profile.d/conda.sh || true

conda activate cardamom

# Determine the directory of the script
BASEDIR=$(cd "$(dirname "$0")" && pwd -P)
OUTPUTDIR="${PWD}/output"
INPUT_FILE=$(ls -d input/*)
CURRENT_TIME=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "${OUTPUTDIR}"

"${BASEDIR}/BASH/CARDAMOM_COMPILE.sh"

"${BASEDIR}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${INPUT_FILE}" "${OUTPUTDIR}/output_param_file_${CURRENT_TIME}.cbr" || true

"${BASEDIR}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${INPUT_FILE}" "${OUTPUTDIR}/output_param_file_${CURRENT_TIME}.cbr" "${OUTPUTDIR}/output_file_${CURRENT_TIME}.nc" || true
