#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Configure S3 Object user and project"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e

# Prepare Object Storage to accept AWSv4 Authentication
echo "===> Preparing S3 Object for AWSv4 Authentication - use US as region with your client software"
sudo mmobj config change --ccrfile "proxy-server.conf" --section "filter:s3api" --property "location" --value "US"

# Copy credentials file to user directory and use it
echo "===> Copy object credentials file and source it"
sudo cp /root/openrc /home/vagrant/openrc
sudo chown vagrant:vagrant /home/vagrant/openrc
source /home/vagrant/openrc

# Create S3 test user with access to the existing admin project
echo "===> Create S3 tests user within admin project"
openstack user create --project admin --password Passw0rd testuser1

# Create S3 credentials for the test user
echo "==> Create S3 credentials for testuser1"
openstack credential create --type ec2 --project admin testuser1 '{"access":"testuser1","secret":"Passw0rd"}'

# Create a new project for S3 exclusive usage
echo "==> Create new project for S3 usage"
openstack project create s3test

# Set admin user for the s3test project
echo "==> Add admin role and S3 credentials for admin user for the s3test project"
openstack role add --project s3test --user admin admin
openstack credential create --type ec2 --project s3test admin '{"access":"admin","secret":"Passw0rd"}'

# Create a user for the s3test project and set S3 credentials
echo "==> Create user for the s3test project and set S3 credentials"
openstack user create --project s3test --password Passw0rd testuser2
openstack role add --project s3test --user testuser2 member
openstack credential create --type ec2 --project s3test testuser2 '{"access":"testuser2","secret":"Passw0rd"}'

# Exit successfully
echo "===> Script completed successfully!"
exit 0
