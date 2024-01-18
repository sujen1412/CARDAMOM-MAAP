#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)

# Check if there's exactly one input file in the input directory
input_files=($(ls -d input/*))
if [ ${#input_files[@]} -ne 1 ]; then
    echo "Error: There should be exactly one input file in the input/ directory."
    exit 1
fi
INPUT_FILE="${input_files[0]}"

# Check if the Conda environment exists, create it if it doesn't
if ! conda info --envs | grep myenv; then
    conda create --name myenv python=3.7 -y
fi

# Activate the Conda environment
eval "$(conda shell.bash hook)"
conda activate myenv

# Install required Conda packages, pinning versions for consistency
conda install -c conda-forge libnetcdf=4.7.4 gcc=9.3.0 -y

# Set LD_LIBRARY_PATH environment variable
export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

# Run the CARDAMOM_COMPILE.sh
"${basedir}/BASH/CARDAMOM_COMPILE.sh"

# Run the CARDAMOM_RUN_MODEL.exe with the provided input file
"${basedir}/C/projects/CARDAMOM_GENERAL/CARDAMOM_RUN_MODEL.exe" "${INPUT_FILE}" "${basedir}/cbrfile.cbr" "output/output_file.nc" || {
    echo "Warning: CARDAMOM_RUN_MODEL.exe exited with an error."
}

# Check if output file was created
if [ ! -f "output/output_file.nc" ]; then
    echo "Error: Output file not created."
    exit 1
fi

# Move outputs into a designated output directory (if needed)
# mkdir -p desired_output_directory
# mv output/output_file.nc desired_output_directory/

# Deactivate the Conda environment
conda deactivate

echo "Script completed successfully."
