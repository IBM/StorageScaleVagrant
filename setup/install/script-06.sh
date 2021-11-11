#!/usr/bin/bash

TASK="Create Spectrum Scale filesystems"

source /vagrant/install/common-preamble.sh

# Show Spectrum Scale filesystem specification
echo "===> Show filesystem specification"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale filesystem list

# Create Spectrum Scale filesystems
echo "===> Create Spectrum Scale filesystems"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale deploy

# Enable quotas
echo "===> Enable quotas"
echo "===> Note: Capacity reports in the GUI depend on enabled quotas"
sudo mmchfs fs1 -Q yes

# Show Spectrum Scale filesystem configuration
echo "===> Show Spectrum Scale filesystem configuration"
sudo mmlsfs all

# Show Spectrum Scale filesystem usage
echo "===> Show Spectrum Scale filesystem usage"
sudo mmdf fs1


# Exit successfully
echo "===> Script completed successfully!"
exit 0
