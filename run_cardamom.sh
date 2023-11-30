#!/bin/bash

set -e

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)

# Log file path
log_file="${basedir}/logs/script_log_$(date '+%Y%m%d_%H%M%S').txt"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Log script start
log "Script started"

# Create and activate a Conda environment
log "Creating and activating Conda environment"
conda create --name myenv python=3.7
eval "$(conda shell.bash hook)"
conda activate myenv

# Install required Conda packages
log "Installing Conda packages"
conda install -c conda-forge libnetcdf gcc parallel

# Set LD_LIBRARY_PATH environment variable
log "Setting LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${basedir}:/opt/conda/lib:$LD_LIBRARY_PATH"

# Run the CARDAMOM_COMPILE.sh
log "Running CARDAMOM_COMPILE.sh"
"${basedir}/BASH/CARDAMOM_COMPILE.sh"

# Function to process a single input file
process_input() {
    local script_dir="$1"
    local input_file="$2"
    
    log "Processing $input_file"
    
    # Debugging: Print current working directory
    log "Current working directory: $(pwd)"
    
    # Run the command and capture output in real-time
    log "Running CARDAMOM_MDF.exe for $input_file"
    "${script_dir}/C/projects/CARDAMOM_MDF/CARDAMOM_MDF.exe" "$input_file" parameter.cbr 2>&1 | tee -a "$log_file"
    
    # Debugging: Print a message after the command
    log "Done processing $input_file"
}

# Find all input files
input_files=(input/*)

# Run the processing in parallel with verbose output
export -f process_input  # Export the function for parallel
log "Running processing in parallel"
parallel --jobs 0 -u --verbose process_input "$basedir" ::: "${input_files[@]}"

# Deactivate the Conda environment
log "Deactivating Conda environment"
conda deactivate

# Log script end
log "Script completed"