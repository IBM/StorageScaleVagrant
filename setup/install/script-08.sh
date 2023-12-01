#!/usr/bin/bash

TASK="Installing Object protocol"

source /vagrant/install/common-preamble.sh

echo "===> configuring Object"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale node add m1.example.com -p
CESVIP=$(grep "cesip" /etc/hosts | awk {'print $1'})
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config protocols -e $CESVIP
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config protocols -f cesShared -m /ibm/cesShared
# Starting with 5.1.9.0, the Swift-based Storage Scale object is no longer
# supported for new installations.
#sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale enable object
#sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config object -f fs1 -m /ibm/fs1 -e cesip.example.com -au admin -dp passw0rd -sp passw0rd -ap passw0rd
#sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config object -s3 on -i 50000
set +e
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale deploy
if [ $? != 0 ]; then
    # CES IP might not yet have been assigned to the node when the deployment is configuring object
    #  -> deployment fails with error "mmobj swift base: No CES IP addresses are assigned to this node"
    # first seen with 5.1.2.2, to work-around sleep a while, then re-try
    sleep 30
    set -e
    sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale deploy
fi
# Exit successfully
echo "===> Script completed successfully!"
exit 0
