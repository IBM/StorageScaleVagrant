#!/usr/bin/bash

TASK="Extract Storage Scale RPMs"

source /vagrant/install/common-preamble.sh

# Pin the version and the edition of Storage Scale, until project runs stable for a while
install=/software/Storage_Scale_Developer-$VERSION-x86_64-Linux-install
# Abort with error code, if Storage Scale directroy exists
echo "===> Check for Storage Scale directrory"
if [ -d "/usr/lpp/mmfs" ]; then
    echo "===> Directory exists: /usr/lpp/mmfs"
    exit 1
fi

# Make self-extracting install package executable
chmod 555 $install

# Extract Storage Scale RPMs
echo "===> Extract Storage Scale PRMs"
sudo $install --silent


# Exit successfully
echo "===> Script completed successfully!"
exit 0
