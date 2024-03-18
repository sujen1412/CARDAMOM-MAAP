#!/bin/bash

set -e

while getopts 'm:r:' flag; do
    case "${flag}" in
    m) RUN_MDF="$OPTARG" ;;
    r) RUN_MODEL="$OPTARG" ;;
    *)
        echo "Usage: $0 [-m true/false] [-r true/false]" >&2
        exit 1
        ;;
    esac
done

basedir=$(cd "$(dirname "$0")" && pwd -P)

OUTPUTDIR="${PWD}/output"
LOGDIR="${PWD}/logs"

mkdir -p "${LOGDIR}" "${OUTPUTDIR}"

LOGFILE="${LOGDIR}/cardamom_run.log"

log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOGFILE"
}

"${basedir}/BASH/CARDAMOM_COMPILE.sh"

export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

run_cardamom() {
    local input_file=$1
    local job_id=$2
    local base_name=$(basename "${input_file}" | sed 's/\(.*\)\..*/\1/')
    local output_param_file="${OUTPUTDIR}/output_param_${base_name}.cbr"
    local output_nc_file="${OUTPUTDIR}/output_file_${base_name}.nc"

    log "Starting job ${job_id} for input ${input_file}"

    if [ "$RUN_MDF" = true ]; then
        if ! "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${input_file}" "${output_param_file}" 2>&1 | tee -a "$LOGFILE"; then
            log "Error in MDF for job ${job_id}"
            return 1
        fi

        log "Completed MDF for job ${job_id}"
    fi

    if [ "$RUN_MODEL" = true ]; then
        if ! "${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${input_file}" "${output_param_file}" "${output_nc_file}" 2>&1 | tee -a "${LOGFILE}"; then
            log "Error in RUN MODEL for job ${job_id}"
            return 1
        fi

        log "Completed job ${job_id}"
    fi
}

export -f run_cardamom log

export basedir OUTPUTDIR LOGDIR LOGFILE

find input/ -type f | parallel -j "$(nproc)" --joblog "${LOGDIR}/parallel_joblog.log" run_cardamom {} {#} 2>&1 | tee -a "${LOGFILE}"
