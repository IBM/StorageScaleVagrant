#!/usr/bin/bash

# ================================
# Initial Information Output
# ================================
echo "========================================================================================="
echo "===> Running script: $0"
echo "===> Showing Storage Scale Filesystem Information"
echo "========================================================================================="

# ================================
# Set Script Execution Options
# ================================
# Print each command before execution
set -x

# Exit immediately if a command returns a non-zero status
set -e

# ================================
# Storage Scale Cluster Information
# ================================
# Show global mount status for the whole Storage Scale cluster
echo "===> Show the global mount status for the whole Storage Scale cluster"
mmlsmount all

# Show the default mount point managed by Storage Scale
echo "===> Show the default mount point managed by Storage Scale"
mmlsfs fs1 -T

# Show the local mount status on the current node
echo "===> Show the local mount status on the current node"
mount | grep /ibm/

# ================================
# Filesystem Content and User Creation
# ================================
# Show content of all Storage Scale filesystems
echo "===> Show content of all Storage Scale filesystems"
find /ibm/

# Create the GUI Admin user for Storage Scale
echo "===> Creating the GUI admin user"
sudo /usr/lpp/mmfs/gui/cli/mkuser admin -g SecurityAdmin -p admin001

# ================================
# REST API Call for Filesystems Info
# ================================
# Show all Storage Scale filesystems using the REST API
echo "===> Fetching all Storage Scale filesystems using the REST API"
curl -k -s -S -X GET --header 'Accept: application/json' -u admin:admin001 'https://localhost/scalemgmt/v2/filesystems/'

# ================================
# Script Completion
# ================================
echo "===> Script completed successfully!"
exit 0
