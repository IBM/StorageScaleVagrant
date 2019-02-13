#!/usr/bin/bash

# Exit on error
set -e

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Tune sensors for demo environment"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Tune sensors for demo environment
echo "===> Tune sensors for demo environment"
sudo mmperfmon config update \
  GPFSPool.restrict=m1.example.com \
  GPFSFileset.restrict=m1.example.com \
  DiskFree.period=300 \
  GPFSFilesetQuota.period=300 \
  GPFSDiskCap.period=300


# Exit successfully
echo "===> Script completed successfully!"
exit 0
