#!/usr/bin/bash

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Extract Spectrum Scale RPMs"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Pin the version and the edition of Spectrum Scale, until project runs stable for a while
#install=/software/Spectrum_Scale_Data_Management-5.1.1.0-x86_64-Linux-install
install=/software/Spectrum_Scale_Developer-5.1.1.0-x86_64-Linux-install
# Abort with error code, if Spectrum Scale directroy exists
echo "===> Check for Spectrum Scale directrory"
if [ -d "/usr/lpp/mmfs" ]; then
    echo "===> Directory exists: /usr/lpp/mmfs"
    exit 1
fi

# Make self-extracting install package executable
chmod 555 $install

# Extract Spectrum Scale RPMs
echo "===> Extract Spectrum Scale PRMs"
sudo $install --silent


# Exit successfully
echo "===> Script completed successfully!"
exit 0
