#!/usr/bin/env -S bash --login
set -euo pipefail
# This script is the one that is called by the DPS.
# Use this script to prepare input paths for any files
# that are downloaded by the DPS and outputs that are
# required to be persisted

# Get current location of build script
basedir=$(dirname "$(readlink -f "$0")")

# Create output directory to store outputs.
# The name is output as required by the DPS.
# Note how we dont provide an absolute path
# but instead a relative one as the DPS creates
# a temp working directory for our code.
# Determine the directory of the script

mkdir -p output

input_filename=$(basename $(ls -d input/*))
current_time=$(date +"%Y-%m-%d_%H-%M-%S")

OUTPUT_PARAM_FILENAME="output_param_file_${input_filename}.cbr"
OUTPUT_FILENAME="output_file_${input_filename}.nc"

conda run --live-stream --name python "${basedir}/../C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "input/${input_filename}" "output/${OUTPUT_PARAM_FILENAME}"
conda run --live-stream --name python "${basedir}/../C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "input/${input_filename}" "output/${OUTPUT_PARAM_FILENAME}" "output/${OUTPUT_FILENAME}"
