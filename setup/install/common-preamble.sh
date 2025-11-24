usage(){
  echo "Usage: $0 <provider> <spectrumscale-version>"
  echo "Supported <provider>:"
  echo "  AWS"
  echo "  VirtualBox"
  echo "  libvirt"
  echo "<spectrumscale-version> is the full version number like $1"
}

# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo -e "===> $TASK"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e

# Exit, if not exactly two arguments are given
if [ $# -ne 2 ]; then
  usage
  exit -1
fi

# Use first argument as current underlying provider
case $1 in
  'AWS'|'VirtualBox'|'libvirt' )
    PROVIDER=$1
    ;;
  *)
    usage $2
    exit -1
    ;;
esac

VERSION=$2
