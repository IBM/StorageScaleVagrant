#!/usr/bin/bash

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Setup management node (m1) as Spectrum Scale Install Node"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Setup management node (m1) as Spectrum Scale Install Node
echo "===> Setup management node (m1) as Spectrum Scale Install Node"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale setup -s 10.1.1.11
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale node list


# Exit successfully
echo "===> Script completed successfully!"
exit 0
