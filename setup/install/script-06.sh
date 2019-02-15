#!/usr/bin/bash

# Exit on error
set -e

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Create Spectrum Scale filesystems"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Show Spectrum Scale filesystem specification
echo "===> Show filesystem specification"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale filesystem list

# Create Spectrum Scale filesystems
echo "===> Create Spectrum Scale filesystems"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale deploy

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
