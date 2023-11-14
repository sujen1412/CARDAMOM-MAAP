#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)

# Create and activate a Conda environment
eval "$(conda shell.bash hook)"
conda activate myenv

# Install required Conda packages
conda install -c conda-forge libnetcdf gcc

# Set LD_LIBRARY_PATH environment variable
export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

# Run the CARDAMOM_COMPILE.sh
"${basedir}/BASH/CARDAMOM_COMPILE.sh"

# Check if an input file argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <input_file_path>"
    exit 1
fi

input_file="${basedir}/$1"

# Run the CARDAMOM_MDF.exe program with the specified arguments in the background with &
"${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${input_file}" parameter.cbr

# Deactivate the Conda environment
conda deactivate
