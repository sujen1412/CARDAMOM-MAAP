#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(
    cd "$(dirname "$0")"
    pwd -P
)

OUTPUTDIR="${PWD}/output"
INPUT_FILE=$(ls -d input/*)

"${basedir}/BASH/CARDAMOM_COMPILE.sh"

# Create and activate a Conda environment
conda create --name myenv python=3.10 -y
eval "$(conda shell.bash hook)"
conda activate myenv

# Install required Conda packages
# Conda install commands
conda install conda-forge::gcc conda-forge::netcdf4 conda-forge::hdf5 -y

gcc --version

# Set LD_LIBRARY_PATH environment variable
export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

# Run the CARDAMOM_MDF.exe with the provided input file
# time "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${INPUT_FILE}" "${basedir}/output_param_file.cbr"

echo "WRITING OUTPUT NC FILE"

time "${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${INPUT_FILE}" "${basedir}/testoutputfile.cbr" "${OUTPUTDIR}/output_file.nc"
