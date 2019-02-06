#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Show Spectrum Scale filesystems"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Show the global mount status for the whole Spectrum Scale cluster
echo "===> Show the global mount status for the whole Spectrum Scale cluster"
mmlsmount all

# Show the default mount point managed by Spectrum Scale
echo "==> Show the default mount point managed by Spectrum Scale"
mmlsfs fs1 -T

# Show the local mount status on the current node
echo "===> Show the local mount status on the current node"
mount | grep /ibm/

# Show content of all Spectrum Scale filesystems
echo "===> Show content of all Spectrum Scale filesystems"
find /ibm/

# Show all Spectrum Scale filesystems using the REST API
echo "==> Show all Spectrum Scale filesystems using the REST API"
curl -k -s -S -X GET --header 'Accept: application/json' -u admin:admin001 'https://localhost/scalemgmt/v2/filesystems/'


# Exit successfully
echo "===> Script completed successfully!"
exit 0
