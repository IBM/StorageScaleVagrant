#!/usr/bin/bash

TASK="Check that Storage Scale self-extracting install package exists"

source /vagrant/install/common-preamble.sh

# Pin the version and the edition of Storage Scale, until project runs stable for a while
install=/software/Storage_Scale_Developer-$VERSION-x86_64-Linux-install
# Abort with error code, if Storage Scale self-extracting installation package not found
echo "===> Check for Storage Scale self-extracting installation package"
if [ ! -f $install ]; then
    echo "===> File not found: $install"
    exit 1
fi


# Exit successfully
echo "===> Script completed successfully!"
exit 0
