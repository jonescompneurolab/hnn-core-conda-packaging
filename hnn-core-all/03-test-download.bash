#!/bin/bash -l

set -e

# This is where $hc comes from, which is where your local HNN-Core source code is located
source ~/.aliases

ENV_NAME=test-conda-download

printf "\n-------------------------------------------"
printf "\n--> Setting up conda env and loading prereqs..."
printf "\n-------------------------------------------\n"

eval "$(/opt/anaconda3/bin/conda shell.bash hook)"

conda activate base
# if conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
#     conda env remove -y -q -n "$ENV_NAME"
# fi
# conda create -y -q -n $ENV_NAME python=3.12
conda activate $ENV_NAME

printf "\n-------------------------------------------"
printf "\n--> Installing built local HNN-Core package..."
printf "\n-------------------------------------------\n"
conda install -y -q hnn-core-all -c jonescompneurolab -c conda-forge

printf "\n-------------------------------------------"
printf "\n--> Running initial checks..."
printf "\n-------------------------------------------\n"
python -c "
from hnn_core import jones_2009_model, simulate_dipole 
simulate_dipole(jones_2009_model(), tstop=20) 
print('--> SUCCESS: The test worked')
"

python -c "
from hnn_core import jones_2009_model, MPIBackend, simulate_dipole
with MPIBackend():
    simulate_dipole(jones_2009_model(), tstop=20)
print('--> SUCCESS: The test worked')
"

printf "\n-------------------------------------------"
printf "\n--> Next, MANUALLY test GUI with MPI..."
printf "\n-------------------------------------------\n"
hnn-gui

printf "\n-------------------------------------------"
printf "\n--> Copying test suite from '../hnn-core' and testing..."
printf "\n-------------------------------------------\n"

# adapted from https://stackoverflow.com/a/53063602
WORKSITE=$(mktemp -d)
cp -r $hc/hnn_core/tests $WORKSITE
cp -r $hc/hnn_core/param $WORKSITE

conda install -y -q pytest pytest-xdist

cd $WORKSITE

printf "\n-------------------------------------------"
printf "\n--> Running only MPI tests..."
printf "\n-------------------------------------------\n"
pytest ./tests -m "uses_mpi"

printf "\n-------------------------------------------"
printf "\n--> NOTE: at least one test probably WILL fail due to test file depencies, and this script will probably exit below. This is expected (for now, until our tests become portable...)"
printf "\n-------------------------------------------\n"
pytest ./tests -m "not uses_mpi" -n auto

# adapted from https://stackoverflow.com/a/53063602
# Make sure the temp directory gets removed on script exit.
trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'rm -rf "$TEMPD"'  EXIT

