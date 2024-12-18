#!/usr/bin/bash

usage(){
  echo "Usage: $0 [<provider>]"
  echo "Supported provider:"
  echo "  AWS"
  echo "  VirtualBox"
  echo "  libvirt"
}

configure_awscli(){
  aws configure set aws_access_key_id $2 --profile $1
  aws configure set aws_secret_access_key $3 --profile $1
  aws configure set endpoint_url https://cesip.example.com:6443  --profile $1
  aws configure set ca_bundle /home/vagrant/aws-cert/cesip-example-com.pem --profile $1
}

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

# Create S3 test users
echo "===> Create S3 tests users"
S3U1=$(mms3 account create s3user1 --gid 1000 --uid 1000 --newBucketsPath /ibm/fs1/examples/buckets | tail -1)
S3U2=$(mms3 account create s3user2 --gid 1000 --uid 1001 --newBucketsPath /ibm/fs1/examples/buckets-u2 | tail -1)
S3U3=$(mms3 account create s3user3 --gid 1002 --uid 1002 --newBucketsPath /ibm/fs1/examples/buckets-u3 | tail -1)

# Configure TLS certificate for S3 access
echo "===> Configure TLS certificate for S3 access"
cd /root
mkdir aws-cert
cd aws-cert
cat <<EOF>san.cnf
[req]
req_extensions = req_ext
distinguished_name = req_distinguished_name
[req_distinguished_name]
CN = localhost
[req_ext]
# The subjectAltName line directly specifies the domain names and IP addresses that the certificate should be valid for.
# This ensures the SSL certificate matches the domain or IP used in your S3 command.
# Example:
# 'DNS:localhost' makes the certificate valid when accessing S3 storage via 'localhost'.
# 'DNS:cess3-domain-name-example.com' adds a specific domain to the certificate. Replace 'cess3- domain-name-example.com' with your actual domain.
# 'IP:<nsfs-server-ip>' includes an IP address. Replace '<nsfs-server-ip>' with the actual IP address of your S3 server.
subjectAltName = DNS:localhost,DNS:cesip.example.com
EOF
sudo openssl genpkey -algorithm RSA -out tls.key
sudo openssl req -new -key tls.key -out tls.csr -config san.cnf -subj "/CN=localhost"
sudo openssl x509 -req -days 365 -in tls.csr -signkey tls.key -out tls.crt -extfile san.cnf -extensions req_ext
sudo mkdir /ibm/cesShared/ces/s3-config/certificates
sudo cp tls.key tls.crt /ibm/cesShared/ces/s3-config/certificates/
sudo mkdir /home/vagrant/aws-cert
sudo cp tls.crt /home/vagrant/aws-cert/cesip-example-com.pem
sudo chown -R vagrant:vagrant /home/vagrant/aws-cert
rm tls.key
cd ..
sudo mmces service stop s3
sudo mmces service start s3

# "S3 Client": Install AWS CLI v2
echo "===> S3 Client: Install AWS CLI v2"
cd /software
curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
dnf -y install unzip
unzip awscliv2.zip 2>&1 >/dev/null
cd aws
sudo ./install
cd ..
rm -rf awscliv2.zip aws

# Wait some time for the service to get online. 10 seconds seem to be fine (issue #59)
echo "===> Wait for the service to settle. Required for VirtualBox/Windows, not required on libvirt/Linux"
sleep 10

# "S3 Client": Configure AWS CLI with user credentials
echo "===> S3 Client: Configure AWS CLI with user credentials"
configure_awscli s3user1 $S3U1
configure_awscli s3user2 $S3U2
configure_awscli s3user3 $S3U3
sudo cp -r /root/.aws /home/vagrant
sudo chown -R vagrant:vagrant /home/vagrant/.aws

# "S3 Client": Test S3 interface
echo "===> S3 Client: Test S3 API operations"
aws --profile s3user1 s3 mb s3://testbucket
aws --profile s3user1 s3 ls

# "S3 Client": Set some aliases
echo "===> S3 Client: Add aliases to shorten S3 CLI, for example use s3 ls."
cat <<EOF>>/home/vagrant/.bashrc
# User specific aliases and functions
alias s3="aws --profile s3user1 s3"
alias s3api="aws --profile s3user1 s3api"
alias s3u2="aws --profile s3user2 s3"
alias s3u2api="aws --profile s3user2 s3api"
alias s3u3="aws --profile s3user3 s3"
alias s3u3api="aws --profile s3user3 s3api"
export AWS_EC2_METADATA_DISABLED=true
EOF

# Exit successfully
echo "===> Script completed successfully!"
exit 0
