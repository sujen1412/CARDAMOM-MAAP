#!/bin/bash

# Stop on any error
set -e


# Activate environment
# shellcheck disable=SC1091
source activate /opt/conda/envs/cardamom || true
conda activate cardamom || true

# Setup directories
basedir=$(cd "$(dirname "$0")" && pwd -P)
OUTPUTDIR="${PWD}/output"

mkdir -p "${OUTPUTDIR}"


# Compile
"${basedir}/BASH/CARDAMOM_COMPILE.sh"

# Function to run CARDAMOM
run_cardamom() {
    local input_file=$1
    local job_id=$2
    
    "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "$input_file" "${OUTPUTDIR}/output_${job_id}.cbr" || true
    "${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "$input_file" "${OUTPUTDIR}/output_${job_id}.cbr" "${OUTPUTDIR}/output_${job_id}.nc" || true
}

export -f run_cardamom

export basedir OUTPUTDIR

# Parallel processing
find input/ -type f | parallel --results output/results -j "$(nproc)" run_cardamom {} '{#}'