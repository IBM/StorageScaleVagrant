#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Show Storage Scale filesystems"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Show the global mount status for the whole Storage Scale cluster
echo "===> Show the global mount status for the whole Storage Scale cluster"
mmlsmount all

# Show the default mount point managed by Storage Scale
echo "==> Show the default mount point managed by Storage Scale"
mmlsfs fs1 -T

# Show the local mount status on the current node
echo "===> Show the local mount status on the current node"
mount | grep /ibm/

# Show content of all Storage Scale filesystems
echo "===> Show content of all Storage Scale filesystems"
find /ibm/

# Create the GUI Admin
echo "==> Create the GUI admin user"
sudo /usr/lpp/mmfs/gui/cli/mkuser admin -g SecurityAdmin -p admin001

# Show all Storage Scale filesystems using the REST API
echo "==> Show all Storage Scale filesystems using the REST API"
curl -k -s -S -X GET --header 'Accept: application/json' -u admin:admin001 'https://localhost/scalemgmt/v2/filesystems/'


# Exit successfully
echo "===> Script completed successfully!"
exit 0
