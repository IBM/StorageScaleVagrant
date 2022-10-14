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
echo "===> Perform all steps to configure Spectrum Scale for demo purposes"
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

# Perform all steps to configure the Spectrum Scale filesystem for demo purposes
/vagrant/demo/script-01.sh
/vagrant/demo/script-02.sh
/vagrant/demo/script-03.sh
#/vagrant/demo/script-04.sh
/vagrant/demo/script-05.sh
/vagrant/demo/script-06.sh
#/vagrant/demo/script-07.sh
/vagrant/demo/script-08.sh $PROVIDER

# Tweak the configuration to show more management capabilities
/vagrant/demo/script-80.sh
/vagrant/demo/script-81.sh
/vagrant/demo/script-99.sh


# Exit successfully
echo "===> Script completed successfully!"
exit 0
