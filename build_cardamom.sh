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
