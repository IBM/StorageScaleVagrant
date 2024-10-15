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

# Copy credentials file to user directory and use it
echo "===> Copy object credentials file and source it"
TARGET=vagrant
if [ "$PROVIDER" = "AWS" ]
then
    TARGET=centos
fi

# Create S3 test users
echo "===> Create S3 tests users"
S3U1=$(mms3 account create s3user1 --gid 1000 --uid 1000 --newBucketsPath /ibm/fs1/examples/buckets | tail -1)
S3U2=$(mms3 account create s3user2 --gid 1000 --uid 1001 --newBucketsPath /ibm/fs1/examples/buckets-u2 | tail -1)
S3U3=$(mms3 account create s3user3 --gid 1002 --uid 1002 --newBucketsPath /ibm/fs1/examples/buckets-u3 | tail -1)

# Install AWS CLI v2
echo "===> Install AWS CLI v2"
cd /software
curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
dnf -y install unzip
unzip awscliv2.zip 2>&1 >/dev/null
cd aws
sudo ./install
cd ..
rm -rf awscliv2.zip aws

# Configure AWS CLI with user credentials
echo "===> Configure AWS CLI with user credentials"
configure_awscli s3user1 $S3U1
configure_awscli s3user2 $S3U2
configure_awscli s3user3 $S3U3
sudo cp -r /root/.aws /home/vagrant
sudo chown -R vagrant:vagrant /home/vagrant/.aws

# Configure TLS certificate for S3 access
echo "===> Configure TLS certificate for S3 access"
cd /home/vagrant
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
cd ..
sudo chown -R vagrant:vagrant aws-cert
sudo mmces service stop s3
sudo mmces service start s3

# Test S3 interface
echo "===> Test S3 API operations"
AWS_CA_BUNDLE=/home/vagrant/aws-cert/tls.crt aws --profile s3user1 --endpoint https://cesip.example.com:6443 s3 mb s3://testbucket
AWS_CA_BUNDLE=/home/vagrant/aws-cert/tls.crt aws --profile s3user1 --endpoint https://cesip.example.com:6443 s3 ls

# Set some aliases
cat <<EOF>>/home/vagrant/.bashrc
# User specific aliases and functions
alias s3="AWS_CA_BUNDLE=/home/vagrant/aws-cert/tls.crt aws --profile s3user1 --endpoint https://cesip.example.com:6443 s3"
alias s3api="AWS_CA_BUNDLE=/home/vagrant/aws-cert/tls.crt aws --profile s3user1 --endpoint https://cesip.example.com:6443 s3api"
alias s3u2="AWS_CA_BUNDLE=/home/vagrant/aws-cert/tls.crt aws --profile s3user2 --endpoint https://cesip.example.com:6443 s3"
alias s3u2api="AWS_CA_BUNDLE=/home/vagrant/aws-cert/tls.crt aws --profile s3user2 --endpoint https://cesip.example.com:6443 s3api"
alias s3u3="AWS_CA_BUNDLE=/home/vagrant/aws-cert/tls.crt aws --profile s3user3 --endpoint https://cesip.example.com:6443 s3"
alias s3u3api="AWS_CA_BUNDLE=/home/vagrant/aws-cert/tls.crt aws --profile s3user3 --endpoint https://cesip.example.com:6443 s3api"
EOF

# Exit successfully
echo "===> Script completed successfully!"
exit 0
