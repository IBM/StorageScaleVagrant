#!/usr/bin/bash

TASK="Extract Spectrum Scale RPMs"

source /vagrant/install/common-preamble.sh

# Pin the version and the edition of Spectrum Scale, until project runs stable for a while
install=/software/Spectrum_Scale_Developer-$VERSION-x86_64-Linux-install
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
