#!/bin/bash

set -e

# shellcheck disable=SC1091
source activate /opt/conda/envs/cardamom || true

# Determine the directory of the script
basedir=$(cd "$(dirname "$0")" && pwd -P)
OUTPUTDIR="${PWD}/output"

mkdir -p "${OUTPUTDIR}"

"${basedir}/BASH/CARDAMOM_COMPILE.sh"
