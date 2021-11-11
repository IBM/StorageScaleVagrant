#!/usr/bin/bash

TASK="Install Spectrum Scale and create a Spectrum Scale cluster"

source /vagrant/install/common-preamble.sh

# Install Spectrum Scale and create Spectrum Scale cluster
echo "===> Install Spectrum Scale and create Spectrum Scale cluster"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale install

## Change admin interface
#  Note: Disable configuration of separate admin network, because
#        this requires reconfiguration of Zimon Collector.
#echo "==> Change admin interface"
#sudo mmchnode -N m1 --admin-interface m1m.example.com

# Show cluster configuration
echo "===> Show cluster configuration"
sudo mmlscluster

# Show node state
echo "===> Show node state"
sudo mmgetstate -a

# Show cluster health
echo "===> Show cluster health"
sudo mmhealth cluster show

# Show node health
echo "===> Show node health"
sudo mmhealth node show

# Show NSDs
echo "===> Show NSDs"
sudo mmlsnsd

# Show GUI service
echo "===> Show GUI service"
service gpfsgui.service status

# Show Zimon Collector service
echo "===> Show Zimon Collector service"
service pmcollector status

# Show Zimon Sensors service
echo "===> Show Zimon Sensors service"
service pmsensors status

# Initialize Spectrum Scale GUI
# Note: The Spectrum Scale GUI initializes implicitly during first login
#       attempt. Initializing the GUI here accelerates the first login.
echo "==> Initialize Spectrum Scale GUI"
sudo /usr/lpp/mmfs/gui/cli/initgui


# Exit successfully
echo "===> Script completed successfully!"
exit 0
