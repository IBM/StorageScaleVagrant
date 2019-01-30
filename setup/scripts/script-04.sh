#!/usr/bin/bash


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


# Specify cluster name to 'demo'
echo "===> Specify cluster name"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale config gpfs -c demo

# Disable callhome for demo environment
echo "===> Specify to disable call home"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale callhome disable

# Specify nodes and its roles
echo "===> Specify nodes and their roles"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale node add -a -q -m -n m1

# Show cluster specification
echo "===> Show cluster specification"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale node list

# Specify NSDs
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale nsd add -p m1.example.com -fs fs1 /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale nsd add -p m1.example.com -fs fs1 -po capacity -u dataOnly /dev/sdg /dev/sdh

# Show NSD specification
echo "===> Show NSD specification"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale nsd list


# Exit successfully
echo "===> Script completed successfully!"
exit 0
