#!/bin/bash

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P) || { echo "Failed to determine script directory."; exit 1; }

# Update package information and install required packages
apt-get update || { echo "Failed to update package information."; exit 1; }
apt-get install -y libnetcdf-dev libnetcdff-dev || { echo "Failed to install required packages."; exit 1; }

# Set LD_LIBRARY_PATH environment variable
export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

# Run the CARDAMOM_COMPILE.sh
"${basedir}/BASH/CARDAMOM_COMPILE.sh" || { echo "Failed to run CARDAMOM_COMPILE.sh."; exit 1; }

# # Run the CARDAMOM_MDF.exe program with the specified arguments in the background with &
# "${basedir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" DATA/CARDAMOM_DEMO_DRIVERS_prototype_1005.cbf.nc parameter.cbr || { echo "Failed to run CARDAMOM_MDF.exe."; exit 1; }