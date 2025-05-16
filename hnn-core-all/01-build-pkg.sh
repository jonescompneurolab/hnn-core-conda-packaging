#!/bin/bash -l

echo $'\n--> Attempting to build the maximal "hnn-core-all" conda package...'

# Need to also include the "defaults" channel, since there is a file clobber/conflict between
# two dependencies if you only use the "conda-forge" channel (as of 20250513)
if [ `uname` == Darwin ]; then
    conda-build recipe -c defaults -c conda-forge
elif [ `uname` == Linux ]; then
    conda-build --prefix-length=80 recipe -c defaults -c conda-forge
    # If the above 'prefix-length' attempt runs into errors, especially with
    # paths or filesystem issues, then you can try uncommenting the following
    # command and using it instead. You may have to run it a couple times for
    # it to work; I have found it to work less consistently than the above
    # command. The below 'croot' method for building on systems where the main
    # partition is encrypted is preferred according to conda-build's
    # documentation, but the 'prefix-length' argument seems to work more
    # reliably for me. However, the documentation claims it is less portable.
    #
    # conda-build --croot=/tmp/asdf recipe -c defaults -c conda-forge
    #
    # Note that if you DO use the croot method, you MUST copy
    # '/tmp/asdf/linux-64' to your '$CONDA_PREFIX/conda-bld', and then run
    # 'conda index' on the latter directory.
fi
