#!/bin/bash

set -e

basedir=$(cd "$(dirname "$0")" && pwd -P)
OUTPUTDIR="${PWD}/output"
nproc=$(nproc)
LOGDIR="${PWD}/logs"

mkdir -p "${LOGDIR}" "${OUTPUTDIR}"

LOGFILE="${LOGDIR}/cardamom_run.log"

# shellcheck disable=SC1091
source activate /opt/conda/envs/cardamom 2>&1 | tee -a "$LOGFILE"

log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOGFILE"
}

log "Directories for output and logs are set."

log "Starting CARDAMOM compilation."
"${basedir}/BASH/CARDAMOM_COMPILE.sh" 2>&1 | tee -a "$LOGFILE"

run_cardamom() {
    local input_file=$1
    local job_id=$2
    local output_param_file="${OUTPUTDIR}/output_param_${job_id}.cbr"
    local output_nc_file="${OUTPUTDIR}/output_file_${job_id}.nc"
    local job_logfile="${LOGDIR}/job_${job_id}.log"

    log "Starting job ${job_id} for input ${input_file}"

    "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${input_file}" "${output_param_file}" 2>&1 | tee -a "$job_logfile" || true
    log "Completed MDF for job ${job_id}"

    "${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${input_file}" "${output_param_file}" "${output_nc_file}" 2>&1 | tee -a "$job_logfile" || true
    log "Completed job ${job_id}"
}

export -f run_cardamom log

export basedir OUTPUTDIR LOGDIR LOGFILE nproc

log "Beginning parallel processing of inputs."
find input/ -type f | parallel -j "${nproc}" --joblog "${LOGDIR}/parallel.log" run_cardamom {} '{#}' 2>&1 | tee -a "${LOGFILE}"
log "Parallel processing complete."
