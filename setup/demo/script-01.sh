#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Show filesystem details"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Show the global mount status for the whole Spectrum Scale cluster
echo "===> Show the global mount status for the whole Spectrum Scale cluster"
mmlsmount all

# Show the local mount status on the current node
echo "===> Show the local mount status on the current node"
mount | grep /ibm/

# Show content of all Spectrum Scale filesystems
echo "===> Show content of all Spectrum Scale filesystems"
find /ibm/

# Show usage of filesystem fs1
echo "===> Show usage of filesystem fs1"
mmdf fs1


# Exit successfully
echo "===> Script completed successfully!"
exit 0
