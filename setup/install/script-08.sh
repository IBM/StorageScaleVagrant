#!/usr/bin/bash

TASK="Installing Object protocol"

source /vagrant/install/common-preamble.sh

echo "===> configuring Object"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale node add m1.example.com -p
CESVIP=$(grep "cesip" /etc/hosts | awk {'print $1'})
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale config protocols -e $CESVIP -f cesShared -m /ibm/cesShared
# Starting with Scale 5.2.1.0, we now install CES S3
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale enable s3

set +e
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale deploy

# Exit successfully
echo "===> Script completed successfully!"
exit 0
