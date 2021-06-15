#!/usr/bin/bash

usage(){
  echo "Usage: $0 [<provider>]"
  echo "Supported provider:"
  echo "  AWS"
  echo "  VirtualBox"
  echo "  libvirt"
}

# Exit on error
set -e

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Installing Object protocol"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e

# Exit, if not exactly one argument given
if [ $# -ne 1 ]; then
  usage
  exit -1
fi

# Use first argument as current underlying provider
case $1 in
  'AWS'|'VirtualBox'|'libvirt' )
    PROVIDER=$1
    ;;
  *)
    usage
    exit -1
    ;;
esac

echo "===> Installing prereqs"
sudo dnf -y install centos-release-openstack-train
sudo dnf config-manager --set-enabled powertools
sudo dnf -y upgrade

echo "===> configuring Object"
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale node add m1.example.com -p
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale config protocols -e 192.168.56.101
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale config protocols -f cesShared -m /ibm/cesShared
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale enable object
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale config object -f fs1 -m /ibm/fs1 -e cesip.example.com -au admin -dp passw0rd -sp passw0rd -ap passw0rd
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale config object -s3 on -i 50000
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale deploy

# Exit successfully
echo "===> Script completed successfully!"
exit 0
