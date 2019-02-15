#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Authorize the default GUI admin to manage ACLs"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Authorize the default admin to manage ACLs
echo "===> Authorize the default GUI admin to manage ACLs"
sudo /usr/lpp/mmfs/gui/cli/chuser admin -a DataAccess


# Exit successfully
echo "===> Script completed successfully!"
exit 0
