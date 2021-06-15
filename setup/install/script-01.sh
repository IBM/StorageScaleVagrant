#!/usr/bin/bash

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Check that Spectrum Scale self-extracting install package exists"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Pin the version and the edition of Spectrum Scale, until project runs stable for a while
#install=/software/Spectrum_Scale_Data_Management-5.1.1.0-x86_64-Linux-install
install=/software/Spectrum_Scale_Developer-5.1.1.0-x86_64-Linux-install
# Abort with error code, if Spectrum Scale self-extracting installation package not found
echo "===> Check for Spectrum Scale self-extracting installation package"
if [ ! -f $install ]; then
    echo "===> File not found: $install"
    exit 1
fi


# Exit successfully
echo "===> Script completed successfully!"
exit 0
