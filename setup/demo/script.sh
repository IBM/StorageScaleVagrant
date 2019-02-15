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


# Perform all steps to configure the Spectrum Scale filesystem for demo purposes
/vagrant/demo/script-01.sh
/vagrant/demo/script-02.sh
/vagrant/demo/script-03.sh
#/vagrant/demo/script-04.sh
/vagrant/demo/script-05.sh
/vagrant/demo/script-06.sh
#/vagrant/demo/script-07.sh

# Tweak the configuration to show more management capabilities
/vagrant/demo/script-99.sh


# Exit successfully
echo "===> Script completed successfully!"
exit 0
