#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)

INPUT_FILE=$(ls -d input/*)

# Create and activate a Conda environment
conda create --name myenv python=3.7
eval "$(conda shell.bash hook)"
conda activate myenv

# Install required Conda packages
conda install -c conda-forge libnetcdf gcc

# Set LD_LIBRARY_PATH environment variable
export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

# Run the CARDAMOM_COMPILE.sh
"${basedir}/BASH/CARDAMOM_COMPILE.sh"

# # Run the CARDAMOM_MDF.exe with the provided input file
# "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${INPUT_FILE}" "${basedir}/parameter.cbr" || true

"${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${INPUT_FILE}" "${basedir}/cbrfile.cbr" "output/output_file.nc" || true

# Move outputs into ouput/ bucket
# Deactivate the Conda environment
conda deactivate
