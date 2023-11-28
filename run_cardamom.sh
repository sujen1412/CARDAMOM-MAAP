#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)

# Create and activate a Conda environment
conda create --name myenv python=3.7
eval "$(conda shell.bash hook)"
conda activate myenv

# Install required Conda packages
conda install -c conda-forge libnetcdf gcc parallel

# Set LD_LIBRARY_PATH environment variable
export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

# Run the CARDAMOM_COMPILE.sh
"${basedir}/BASH/CARDAMOM_COMPILE.sh"

# Function to process a single input file
process_input() {
    basedir="$1"
    input_file="$2"

    echo "Processing $input_file"

    # Debugging: Print current working directory
    echo "Current working directory: $(pwd)"

    # Run the command and capture output in real-time
    "${basedir}"/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe "$input_file" parameter.cbr

    # Debugging: Print a message after the command
    echo "Done processing $input_file"
}

# Find all input files
input_files=(input/*)

# Run the processing in parallel with verbose output
export -f process_input # Export the function for parallel
parallel --jobs 0 --verbose process_input "$basedir" ::: "${input_files[@]}"

# Deactivate the Conda environment
conda deactivate
