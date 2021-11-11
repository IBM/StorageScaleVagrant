#!/usr/bin/bash

TASK="Tune sensors for demo environment"

source /vagrant/install/common-preamble.sh

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
