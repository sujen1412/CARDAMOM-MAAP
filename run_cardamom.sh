#!/bin/bash

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" || exit; pwd -P)

# Update package information and install required packages
apt-get update
apt-get install libnetcdf-dev libnetcdff-dev

# Set LD_LIBRARY_PATH environment variable
export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

# Run the CARDAMOM_COMPILE.sh
"${basedir}"/BASH/CARDAMOM_COMPILE.sh

# Run the CARDAMOM_MDF.exe program with the specified arguments in the background with &
"${basedir}"/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe DATA/CARDAMOM_DEMO_DRIVERS_prototype_1005.cbf.nc parameter.cbr
