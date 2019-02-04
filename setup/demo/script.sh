#!/usr/bin/bash

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Perform all steps to configure Spectrum Scale for demo purposes"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Perform all steps to configure Spectrum Scale for demo purposes
/vagrant/demo/script-01.sh


# Exit successfully
echo "===> Script completed successfully!"
exit 0
