#!/usr/bin/bash

TASK="Install Storage Scale and create a Storage Scale cluster"

source /vagrant/install/common-preamble.sh

# Install Storage Scale and create Storage Scale cluster
echo "===> Install Storage Scale and create Storage Scale cluster"
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
sudo systemctl status --no-pager gpfsgui

# Show Zimon Collector service
echo "===> Show Zimon Collector service"
sudo systemctl status --no-pager pmcollector

# Show Zimon Sensors service
echo "===> Show Zimon Sensors service"
sudo systemctl status --no-pager pmsensors

# Initialize Storage Scale GUI
# Note: The Storage Scale GUI initializes implicitly during first login
#       attempt. Initializing the GUI here accelerates the first login.
echo "==> Initialize Storage Scale GUI"
sudo /usr/lpp/mmfs/gui/cli/initgui

# Issue #58: Immediately create a GUI user
echo "==> Create GUI user for monitoring purposes"
sudo /usr/lpp/mmfs/gui/cli/mkuser performance -g Monitor -p monitor

# Exit successfully
echo "===> Script completed successfully!"
exit 0
