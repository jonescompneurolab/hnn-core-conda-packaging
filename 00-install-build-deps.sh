#!/bin/bash -l

echo $'\n--> Preparing to install dependencies for building Conda packages...'
echo $'--> NOTE: To build conda packages, it is recommended that you DO use the "base" environment, NOT a custom environment, unlike normal conda usage. This script attempts to install the necessary packages into the "base" environment.'
echo $'You only need to run this script once.'
echo $'\nSee https://docs.conda.io/projects/conda-build/en/stable/install-conda-build.html for more details.'

conda activate base
conda install -y -q conda-build
