#!/usr/bin/bash

TASK="Perform all steps to provision a Storage Scale cluster"

source /vagrant/install/common-preamble.sh

# Perform all steps to provision Storage Scale Cluster
/vagrant/install/script-01.sh $PROVIDER $VERSION
/vagrant/install/script-02.sh $PROVIDER $VERSION
/vagrant/install/script-03.sh $PROVIDER $VERSION
/vagrant/install/script-04.sh $PROVIDER $VERSION
/vagrant/install/script-05.sh $PROVIDER $VERSION
/vagrant/install/script-06.sh $PROVIDER $VERSION
/vagrant/install/script-07.sh $PROVIDER $VERSION
/vagrant/install/script-08.sh $PROVIDER $VERSION
# Exit successfully
echo "===> Script completed successfully!"
exit 0
