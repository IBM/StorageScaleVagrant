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
echo "===> Setup management node (m1) as Spectrum Scale Install Node"
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

# Determine SpectrumScale Install Node
# ... for AWS
if [ "$PROVIDER" = "AWS" ]
then
  INSTALL_NODE=`hostname -I`
fi
# ... for VirtualBox
if [ "$PROVIDER" = "Virtualbox" ]
then
  INSTALL_NODE="10.1.1.11"
fi

# Setup management node (m1) as Spectrum Scale Install Node
echo "===> Setup management node (m1) as Spectrum Scale Install Node"
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale node list
sudo /usr/lpp/mmfs/5.0.2.2/installer/spectrumscale setup -s $INSTALL_NODE


# Exit successfully
echo "===> Script completed successfully!"
exit 0
