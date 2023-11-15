#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)

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

# Run the CARDAMOM_MDF.exe
"${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "${basedir}/DATA/CARDAMOM_DEMO_DRIVERS.cbf.nc" parameter.cbr

# Deactivate the Conda environment
conda deactivate
