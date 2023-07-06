#!/usr/bin/bash

TASK="Create Storage Scale filesystems"

source /vagrant/install/common-preamble.sh

# Show Storage Scale filesystem specification
echo "===> Show filesystem specification"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale filesystem list

# Create Storage Scale filesystems
echo "===> Create Storage Scale filesystems"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale deploy

# Enable quotas
echo "===> Enable quotas"
echo "===> Note: Capacity reports in the GUI depend on enabled quotas"
sudo mmchfs fs1 -Q yes

# Show Storage Scale filesystem configuration
echo "===> Show Storage Scale filesystem configuration"
sudo mmlsfs all

# Show Storage Scale filesystem usage
echo "===> Show Storage Scale filesystem usage"
sudo mmdf fs1


# Exit successfully
echo "===> Script completed successfully!"
exit 0
