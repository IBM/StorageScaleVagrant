#!/usr/bin/bash

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Perform all steps to provision a Spectrum Scale cluster"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Perform all steps to provision Spectrum Scale Cluster
/vagrant/scripts/script-01.sh
/vagrant/scripts/script-02.sh
/vagrant/scripts/script-03.sh
/vagrant/scripts/script-04.sh
/vagrant/scripts/script-05.sh
/vagrant/scripts/script-06.sh


# Exit successfully
echo "===> Script completed successfully!"
exit 0
