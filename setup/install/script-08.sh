#!/usr/bin/bash

TASK="Installing Object protocol"

source /vagrant/install/common-preamble.sh

echo "===> Installing prereqs"
sudo dnf -y install centos-release-openstack-train
sudo dnf config-manager --set-enabled powertools
sudo dnf -y upgrade

echo "===> configuring Object"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale node add m1.example.com -p
CESVIP=$(grep "cesip" /etc/hosts | awk {'print $1'})
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config protocols -e $CESVIP
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config protocols -f cesShared -m /ibm/cesShared
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale enable object
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config object -f fs1 -m /ibm/fs1 -e cesip.example.com -au admin -dp passw0rd -sp passw0rd -ap passw0rd
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config object -s3 on -i 50000
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale deploy

# Exit successfully
echo "===> Script completed successfully!"
exit 0
