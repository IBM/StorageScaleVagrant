#!/usr/bin/bash

usage(){
  echo "Usage: $0 [<provider>]"
  echo "Supported provider:"
  echo "  AWS"
  echo "  VirtualBox"
  echo "  libvirt"
}


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Specify Spectrum Scale Cluster"
echo "===> Target configuration: Single Node Cluster"
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


# Specify cluster name to 'demo'
echo "===> Specify cluster name"
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale config gpfs -c demo

# Disable callhome for demo environment
echo "===> Specify to disable call home"
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale callhome disable

# Specify nodes and its roles
echo "===> Specify nodes and their roles"
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale node add -a -g -q -m -n m1

# Show cluster specification
echo "===> Show cluster specification"
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale node list

# Specify NSDs
# ... for AWS
if [ "$PROVIDER" = "AWS" ]
then
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com -fs fs1 /dev/xvdb /dev/xvdc /dev/xvdd
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com -fs cesShared /dev/xvde /dev/xvdf
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com /dev/xvdg /dev/xvdh
fi
# ... for VirtualBox
if [ "$PROVIDER" = "VirtualBox" ]
then
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com -fs fs1 /dev/sdb /dev/sdc /dev/sdd
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com -fs cesShared /dev/sde /dev/sdf
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com /dev/sdg /dev/sdh
fi
# ... and Libvirt
if [ "$PROVIDER" = "libvirt" ]
then
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com -fs fs1 /dev/vdb /dev/vdc /dev/vdd
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com -fs cesShared /dev/vde /dev/vdf
  sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd add -p m1.example.com /dev/vdg /dev/vdh
fi

# Show NSD specification
echo "===> Show NSD specification"
sudo /usr/lpp/mmfs/5.1.1.0/ansible-toolkit/spectrumscale nsd list


# Exit successfully
echo "===> Script completed successfully!"
exit 0
