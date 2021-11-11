#!/usr/bin/bash

TASK="Setup management node (m1) as Spectrum Scale Install Node"

source /vagrant/install/common-preamble.sh

# Determine SpectrumScale Install Node
# ... for AWS
if [ "$PROVIDER" = "AWS" ]
then
  INSTALL_NODE=`hostname -I`
fi
# ... for VirtualBox
if [ "$PROVIDER" = "VirtualBox" -o "$PROVIDER" = "libvirt" ]
then
  INSTALL_NODE="10.1.1.11"
fi

# Setup management node (m1) as Spectrum Scale Install Node
echo "===> Setup management node (m1) as Spectrum Scale Install Node"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale setup -s $INSTALL_NODE --storesecret
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale node list


# Exit successfully
echo "===> Script completed successfully!"
exit 0
