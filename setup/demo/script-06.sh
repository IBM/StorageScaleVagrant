#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Create snapshot for fileset snapshots"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Create fileset to demonstrate snapshots
echo "===> Create fileset to demonstrate snapshots"
sudo mmcrfileset fs1 snapshots -t 'Some snapshots' --inode-space new --inode-limit 1024 

# Link filesets
echo "===> Link fileset"
sudo mmlinkfileset fs1 snapshots -J /ibm/fs1/examples/snapshots

# Allow all users to read the directory
echo "===> Allow all users to read the directory"
sudo chmod 755 /ibm/fs1/examples/snapshots

# Create files before the snapshot
echo "===> Create files before snapshot"
echo "This line was written before the snapshot" | sudo tee /ibm/fs1/examples/snapshots/file1 > /dev/null
echo "This line was written before the snapshot" | sudo tee /ibm/fs1/examples/snapshots/file2 > /dev/null

# Create snapshot
echo "===> Create snapshot"
sudo mmcrsnapshot fs1 milestone_1602 -j snapshots

# Update files after the snapshot
echo "===> Update files after the snapshot"
echo "This line was written after the snapshot" | sudo tee --append /ibm/fs1/examples/snapshots/file1 > /dev/null
sudo rm /ibm/fs1/examples/snapshots/file2
echo "This line was written after the snapshot" | sudo tee --append /ibm/fs1/examples/snapshots/file3 > /dev/null

# Show snapshots
echo "===> Show snapshots"
sudo mmlssnapshot fs1

# Show current files
echo "===> Show current files"
wc -l /ibm/fs1/examples/snapshots/*

# Show files in snapshot
echo "===> Show files in snapshot"
wc -l /ibm/fs1/examples/snapshots/.snapshots/milestone_1602/*


# Exit successfully
echo "===> Script completed successfully!"
exit 0
