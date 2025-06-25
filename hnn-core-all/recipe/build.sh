#!/bin/bash

echo "========================================================================"
echo "Building ${PKG_NAME} for MacOS or Linux"
echo ""


if [ `uname` == Darwin ]; then
    if [ `uname -m` == arm64 ]; then
        NRN_WHL_URL=https://files.pythonhosted.org/packages/fe/d0/a22eceadcb655aa03a8a37f6e109e0880a7d00978713f0f5ded8042cfb5f/neuron-8.2.7-cp312-cp312-macosx_11_0_arm64.whl
    elif [ `uname -m` == x86_64 ]; then
        NRN_WHL_URL=https://files.pythonhosted.org/packages/ab/45/26a87553e7a1dde05fb9aebe98715498b6273fd0ed08f5a82ad550ee5379/neuron-8.2.7-cp312-cp312-macosx_10_15_x86_64.whl
    fi
    # Adapted from https://docs.conda.io/projects/conda-build/en/latest/resources/activate-scripts.html
    for CHANGE in "activate" "deactivate"
    do
        mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
        cp "${RECIPE_DIR}/env_scripts/${CHANGE}_osx.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    done
fi

if [ `uname` == Linux ]; then
    # Note that as of NEURON 8.2.7 (checked 2025-06-24 at https://pypi.org/project/NEURON/8.2.7/#files ), NEURON are no longer distributing Linux ARM wheels
    if [ `uname -m` == x86_64 ]; then
        NRN_WHL_URL=https://files.pythonhosted.org/packages/3e/69/5a8d498fd3096726768ab875b0e9a633cfdb68f976a6d520b6158b07ed7c/neuron-8.2.7-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
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
