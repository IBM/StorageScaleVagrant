#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Create placement policy for filesystem fs1"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Show file that contains the placement rules
echo "===> Show file that contains the placement rules"
cat /vagrant/files/spectrumscale/fs1-placement-policy

# Activate placement rules
echo "===> Activate placement rules"
sudo mmchpolicy fs1 /vagrant/files/spectrumscale/fs1-placement-policy

# Show all active rules
echo "===> Show all active rules"
mmlspolicy fs1

# Create example directory to demonstrate placement rules
echo "===> Create example directory to demonstrate placement rules"
sudo mkdir -p /ibm/fs1/examples/placement_policy

# Create file that will be placed in the system storage pool
echo "===> Create file that will be placed in the system storage pool"
sudo bash -c 'echo "This file will be placed in the system storage pool" > /ibm/fs1/examples/placement_policy/file.hot'

# Create file that will be placed in the capacity storage pool
echo "===> Create file that will be placed in the capacity storage pool"
sudo bash -c 'echo "This file will be placed in the capacity storage pool" > /ibm/fs1/examples/placement_policy/file.txt'

# Show that hot file is placed in the system storage pool
echo "===> Show that hot file is placed in the system storage pool"
mmlsattr -L /ibm/fs1/examples/placement_policy/file.hot | grep 'storage pool name'

# Show that default file is placed in the capacity storage pool
echo "===> Show that default file is placed in the capacity storage pool"
mmlsattr -L /ibm/fs1/examples/placement_policy/file.txt | grep 'storage pool name'

# Show that Storage Scale storage pools are not visible to end users
echo "===> Show that Storage Scale storage pools are not visible to end users"
ls -la /ibm/fs1/examples/placement_policy
wc -l /ibm/fs1/examples/placement_policy/file*


# Exit successfully
echo "===> Script completed successfully!"
exit 0
