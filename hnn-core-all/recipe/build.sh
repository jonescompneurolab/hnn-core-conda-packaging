#!/bin/bash

echo "========================================================================"
echo "Building ${PKG_NAME} for MacOS or Linux"
echo ""


if [ `uname` == Darwin ]; then
    if [ `uname -m` == arm64 ]; then
        NRN_WHL_URL=https://files.pythonhosted.org/packages/76/89/4e659723194edb3351a37b60a474843e68f676bc983c41047c234b544494/NEURON-8.2.6-cp312-cp312-macosx_11_0_arm64.whl
    elif [ `uname -m` == x86_64 ]; then
        NRN_WHL_URL=https://files.pythonhosted.org/packages/d7/52/50ae4bf3dcc87cf71daa559f1b188b4a8e85f7f19073d976eb12821f8692/NEURON-8.2.6-cp312-cp312-macosx_10_15_x86_64.whl
    fi
    # Adapted from https://docs.conda.io/projects/conda-build/en/latest/resources/activate-scripts.html
    for CHANGE in "activate" "deactivate"
    do
        mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
        cp "${RECIPE_DIR}/env_scripts/${CHANGE}_osx.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    done
fi

if [ `uname` == Linux ]; then
    if [ `uname -m` == x86_64 ]; then
        NRN_WHL_URL=https://files.pythonhosted.org/packages/14/4e/e0c65911a59b646274ba4f6740e8705ff29863879b0a629e92666d682ebd/NEURON-8.2.6-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
    fi
    # Adapted from https://docs.conda.io/projects/conda-build/en/latest/resources/activate-scripts.html
    for CHANGE in "activate" "deactivate"
    do
        mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
        cp "${RECIPE_DIR}/env_scripts/${CHANGE}_linux.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    done
fi

${PYTHON} -m pip install --no-deps ${NRN_WHL_URL}

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
