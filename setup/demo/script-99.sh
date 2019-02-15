#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Tweak GUI screens"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Initialize quota database
echo "===> Initialize quota database"
sudo mmcheckquota fs1

# Update capacity reports
echo "===> Update capacity reports"
sudo /usr/lpp/mmfs/gui/cli/runtask QUOTA


# Exit successfully
echo "===> Script completed successfully!"
exit 0
