#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)

OUTPUTDIR="${PWD}/output"
LOGDIR="${PWD}/logs"

# Ensure the directories exist
mkdir -p "${LOGDIR}" "${OUTPUTDIR}"

# Log file common for all runs
LOGFILE="${LOGDIR}/cardamom_run.log"

log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOGFILE"
}

# Default values for running components are false
export RUN_MDF=false
export RUN_MODEL=false
export IS_TEST_RUN=false

# Check positional arguments
if [[ $1 == "true" ]]; then
    RUN_MDF=true
fi

if [[ $2 == "true" ]]; then
    RUN_MODEL=true
fi

if [[ $3 == "true" ]]; then
    IS_TEST_RUN=true
fi

run_cardamom() {
    local input_file=$1
    local job_id=$2
    local base_name=$(basename "${input_file}" | sed 's/\(.*\)\..*/\1/')
    local output_param_file="${OUTPUTDIR}/output_param_${base_name}.cbr"
    local output_nc_file="${OUTPUTDIR}/output_file_${base_name}.nc"

    log "Starting job ${job_id} for input ${input_file}"

    if [ "$RUN_MDF" = "true" ]; then
        time "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${input_file}" "${output_param_file}" 2>&1 | tee -a "$LOGFILE"
        log "Completed MDF for job ${job_id}"
    fi

    if [ "$RUN_MODEL" = "true" ]; then
        "${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${input_file}" "${output_param_file}" "${output_nc_file}" 2>&1 | tee -a "${LOGFILE}"
        log "Completed job ${job_id}"
    fi

    if [ "$IS_TEST_RUN" = "true" ]; then
        time "${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${basedir}/input/PROJSCRIPT_CARDAMOM_CMSFLUX_PRIORS_JUL23_V1_1942.cbf.nc" "${basedir}/cbrfile.cbr" "${OUTPUTDIR}/output_file_test.nc" 2>&1 | tee -a "${LOGFILE}"
    fi
}

export -f run_cardamom log

export basedir OUTPUTDIR LOGDIR LOGFILE

# Execute for all input files
find input/ -type f | parallel -j "$(nproc)" --joblog "${LOGDIR}/parallel_joblog.log" run_cardamom {} {#} 2>&1 | tee -a "${LOGFILE}"
