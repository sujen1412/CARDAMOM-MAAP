#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)

OUTPUTDIR="${PWD}/output"
LOGDIR="${PWD}/logs"

# Ensure the directories exist
mkdir -p "${LOGDIR}" "${OUTPUTDIR}"

# Log file common for all runs, but you could also make this specific to runs if desired
LOGFILE="${LOGDIR}/cardamom_run.log"

log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOGFILE"
}

"${basedir}/BASH/CARDAMOM_COMPILE.sh"

export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

run_cardamom() {
    local input_file=$1
    local job_id=$2
    # Extract the base name of the input file without its extension for use in output file naming
    local base_name=$(basename "${input_file}" | sed 's/\(.*\)\..*/\1/')

    # Modify file names to include the base name of the input file
    local output_param_file="${OUTPUTDIR}/output_param_${base_name}.cbr"
    local output_nc_file="${OUTPUTDIR}/output_file_${base_name}.nc"

    log "Starting job ${job_id} for input ${input_file}"

    if ! time "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${input_file}" "${output_param_file}" 2>&1 | tee -a "$LOGFILE"; then
        log "Error in MDF for job ${job_id}"
        return 1
    fi

    log "Completed MDF for job ${job_id}"

    if ! time "${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${input_file}" "${output_param_file}" "${output_nc_file}" 2>&1 | tee -a "${LOGFILE}"; then
        log "Error in RUN MODEL for job ${job_id}"
        return 1
    fi

    log "Completed job ${job_id}"
}

export -f run_cardamom log

export basedir OUTPUTDIR LOGDIR LOGFILE

find input/ -type f | parallel -j "$(nproc)" --joblog "${LOGDIR}/parallel_joblog.log" run_cardamom {} {#} 2>&1 | tee -a "${LOGFILE}"
