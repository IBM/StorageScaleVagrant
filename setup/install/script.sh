#!/usr/bin/bash


usage(){
  echo "Usage: $0 [<provider>]"
  echo "Supported provider:"
  echo "  AWS"
  echo "  Virtualbox"
}


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Perform all steps to provision a Spectrum Scale cluster"
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
  'AWS'|'Virtualbox' )
    PROVIDER=$1
    ;;
  *)
    usage
    exit -1
    ;;
esac


# Perform all steps to provision Spectrum Scale Cluster
/vagrant/install/script-01.sh $PROVIDER
/vagrant/install/script-02.sh $PROVIDER
/vagrant/install/script-03.sh $PROVIDER
/vagrant/install/script-04.sh $PROVIDER
/vagrant/install/script-05.sh $PROVIDER
/vagrant/install/script-06.sh $PROVIDER
/vagrant/install/script-07.sh $PROVIDER

# Exit successfully
echo "===> Script completed successfully!"
exit 0
