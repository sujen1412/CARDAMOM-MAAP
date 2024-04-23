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

input_filename=$(ls -d input/*)
current_time=$(date +"%Y-%m-%d_%H-%M-%S")

conda run --live-stream --name vanilla "${basedir}/BASH/CARDAMOM_COMPILE.sh"

echo "Running CARDAMOM MDF"

conda run --live-stream --name vanilla "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${input_filename}" "output/output_param_file_${current_time}.cbr"

echo "Running CARDAMOM MODEL"

conda run --live-stream --name vanilla "${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${input_filename}" "output/output_param_file_${current_time}.cbr" "output/output_file_${current_time}.nc"