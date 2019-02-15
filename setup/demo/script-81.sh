#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Trigger health events by filesets that exceed thresholds"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Create filesets
echo "===> Create filesets"
sudo mmcrfileset fs1 exceed_warning_threshold -t 'Exceed warning threshold' --inode-space new --inode-limit 1024 
sudo mmcrfileset fs1 exceed_error_threshold   -t 'Exceed error threshold'   --inode-space new --inode-limit 1024 

# Link filesets
sudo mmlinkfileset fs1 exceed_warning_threshold -J /ibm/fs1/examples/exceed_warning_threshold
sudo mmlinkfileset fs1 exceed_error_threshold   -J /ibm/fs1/examples/exceed_error_threshold

# Create files to exceed warning threshold
echo "===> Create files to exceed warning threshold"
for i in {1..850}; do
  sudo touch /ibm/fs1/examples/exceed_warning_threshold/file$i
done

# Create files to exceed warning threshold
echo "===> Create files to exceed error threshold"
for i in {1..950}; do
  sudo touch /ibm/fs1/examples/exceed_error_threshold/file$i
done


# Exit successfully
echo "===> Script completed successfully!"
exit 0
