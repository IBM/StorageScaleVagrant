#!/usr/bin/bash

TASK="Install Storage Scale and create a Storage Scale cluster"

source /vagrant/install/common-preamble.sh

# Create certificate required for REST API v3
echo "===> Create certificate required for REST API v3"
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale scaleadmd enable
sudo mkdir /root/tls
sudo openssl ecparam -name prime256v1 -genkey -noout -out /root/tls/ca.key
sudo openssl req -new -x509 -sha256 -key /root/tls/ca.key -out /root/tls/ca.crt -subj "/C=DE/ST=NewYork/L=Armonk/O=IBM/CN=`hostname`" -days 10000
sudo openssl ecparam -name prime256v1 -genkey -noout -out /root/tls/server.key
sudo openssl req -new -sha256 -key /root/tls/server.key -out /root/tls/server.csr -subj "/C=DE/ST=NewYork/L=Armonk/O=IBM/CN=demo.example.com"
sudo openssl x509 -req -in /root/tls/server.csr -CA /root/tls/ca.crt -CAkey /root/tls/ca.key -CAcreateserial -out /root/tls/server.pem -days 10000 -sha256
sudo openssl verify -CAfile /root/tls/ca.crt /root/tls/server.pem
sudo /usr/lpp/mmfs/$VERSION/ansible-toolkit/spectrumscale nodeid define --cert /root/tls/server.pem --key /root/tls/server.key --chain /root/tls/ca.crt -N all
sudo firewall-cmd --add-port=50052/tcp --permanent
sudo firewall-cmd --add-port=46443/tcp --permanent
sudo firewall-cmd --reload

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
sudo /usr/lpp/mmfs/gui/cli/mkuser performance -g Monitor -p monitoring

# Check REST API v3
sudo scalectl apihealth get m1.example.com
sudo scalectl authorization cani -a create -r '/scalemgmt/v3/filesystems'
sudo mmcommon checkscaleapienabled
sudo useradd performance
echo "monitoring" | sudo passwd --stdin performance
sudo useradd admin
echo "supersecret" | sudo passwd --stdin admin
sudo scalectl authorization domain update StorageScaleDomain -F /vagrant/files/spectrumscale/restapi-policy.json
# The following commands list the authorization domains in detail, skipping here as too verbose
#sudo scalectl authorization domain list
#sudo scalectl authorization domain get StorageScaleDomain

# Exit successfully
echo "===> Script completed successfully!"
exit 0
