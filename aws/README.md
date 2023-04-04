# Storage Scale Vagrant for AWS

The scripts and files in this directory include the tooling to provision and
configure the example Storage Scale cluster on AWS.

## Install the Vagrant plugin for AWS (vagrant-aws)

After installing [Storage Scale Vagrant and Vagrant itself](../README.md) you
need to install the [vagrant-aws plugin](https://github.com/mitchellh/vagrant-aws)
to enable Vagrant to manage virtual environments on AWS.

On Windows 10 hosts, the installation of the vagrant-aws plugin might fail, but [pinning the
version of fog-ovirt](https://github.com/mitchellh/vagrant-aws/issues/539#issuecomment-398100794)
resolves the issue:

```
vagrant plugin install --plugin-version 1.0.1 fog-ovirt
vagrant plugin install vagrant-aws
```

On Ubuntu 20.04 it is required to install an additional dependency to pass the vagrant-aws
plugin installation:

```
sudo apt install libcurl4-openssl-dev
vagrant plugin install vagrant-aws
```

## Get the dummy box for the vagrant-aws plugin

Vagrant requires each provider plug-in to provide its own box format. The
vagrant-aws plugin provides a [dummy box](https://github.com/mitchellh/vagrant-aws#box-format)
to get the plugin going. In contrast to other box formats this box format does
not include images of virtual machines. Instead the `Vagrantfile` needs to specify
the AMI ID of an available AWS AMI.

To [add the vagrant-aws dummy box](https://github.com/mitchellh/vagrant-aws#quick-start)
to your Vagrant installation:

```
vagrant box add aws-dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
```

## Configure your AWS access key and your SSH key pair

Copy the `Vagrantfile.aws-credentials.sample` to `Vagrantfile.aws-credentials` and update that file with your credentials:

```
cd SpectrumScaleVagrant\aws
copy Vagrantfile.aws-credentials.sample Vagrantfile.aws-credentials
notepad Vagrantfile.aws-credentials
```

See the AWS documentation ([Managing Access Keys for IAM Users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
and [Amazon EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html))
on how to get the AWS access key and the ssh key.

## Accept the CentOS license agreement on AWS marketplace

At the point of writing this README, there is no charge for using the CentOS software,
but before using CentOS you need to find [CentOS 8 on the AWS marketplace](https://aws.amazon.com/marketplace/pp/prodview-ndxelprnnxecs)
and to subscribe it in order to accept the license agreement.

## Decide on how to integrate the Storage Scale self-extracting installation package

Depending on your network connectivity, it takes some time to upload the Storage Scale self-extracting installation package into AWS. There are two approach options to optimize the creation of the AWS AMI image for Storage Scale:
1. Save the self-extracting installation package to `SpectrumScaleVagrant\software` before you to boot the virtual machine from which you create the Storage Scale AWS AMI. Then Vagrant will automatically copy it during the provisioning process (`Vagrant up`) from your host to the virtual machine in AWS.
1. Copy the self-extracting installation package to `/software` of your virtual machine, after you have booted it. This approach is faster, if you have a copy for instance in an S3 bucket.

## Spectrum Scale Base AMI - An AWS AMI optimized for Storage Scale

The virtual machines are based on the official CentOS/8 AWS AMI. Storage Scale requires a couple of additional RPMs. We create a custom Storage Scale Base AMI to accelerate the provisioning of the virtual machines for the Storage Scale environment.

To start the initial virtual machine:
1. `cd SpectrumScaleVagrant\aws\prep-ami`
1. `Vagrant up`
1. `Vagrant ssh`

Copy the Storage Scale self-extracting installation package to `/software`, if you decided for approach option 2 above.

```
SpectrumScaleVagrant\aws\prep-ami>vagrant ssh

[centos@ip-172-31-27-143 ~]$ ls -l software/
total 1527996
-rw-r--r--. 1 centos centos        134  4. Apr 12:22 README
-rw-r--r--. 1 centos centos 1564648029  8. MÃ¤r 13:56 Spectrum_Scale_Developer-5.1.7.0-x86_64-Linux-install
-rw-r--r--. 1 centos centos         88  8. MÃ¤r 13:56 Spectrum_Scale_Developer-5.1.7.0-x86_64-Linux-install.md5

[centos@ip-172-31-27-143 ~]$ exit
logout
Connection to ec2-34-224-86-55.compute-1.amazonaws.com closed.

SpectrumScaleVagrant\aws\prep-ami>
```

Having checked that `DeleteOnTermination` is set to `true` (see [Appendix](#appendix-avoid-orphaned-root-volumes)) we can build the Storage Scale AWS AMI and terminate the virtual machine:
1. `vagrant package SpectrumScale_base --output SpectrumScale_base.box`
1. `vagrant destroy`

If `vagrant package` fails with the error message `Malformed => AMI names must be between 3 and 128 characters long, and may contain letters, numbers, '(', ')', '.', '-', '/' and '_'`
you need to apply a patch described in the [Appendix](#appendix-fix-for-vagrant-aws-packaging) to your local copy of vagrant-aws and try again.


## Configure the SpectrumScale_base AMI ID

The `vagrant package ...` command of the previous step prints the AMI ID of the new SpectrumScale_base AMI:

```
...
==> SpectrumScale_base: Waiting for the AMI 'ami-05d550f0ea6e84325' to burn...
...
```

Copy the `Vagrantfile.aws-ami.sample` to `Vagrantfile.aws-ami` and update that file with the AMI ID of the SpectrumScale_base AMI:

```
cd SpectrumScaleVagrant\aws
copy Vagrantfile.aws-ami.sample Vagrantfile.aws-ami
notepad Vagrantfile.aws-ami
```

## Boot a virtual machine with a single node Storage Scale cluster

Now we are ready to boot a virtual machine on AWS and to configure it with a single node Storage Scale cluster:
1. `cd SpectrumScaleVagrant\aws`
1. `vagrant up`
1. `vagrant ssh`

See the [README.md](../README.md) for details on the configured Storage Scale cluster.


## Appendix: Avoid orphaned root volumes

Versions of the official CentOS AMI and derived AMIs might leave the orphaned root volume, after the owning virtual machine (instance) is terminated.
Amazon charges for orphaned root volumes. They either need to be deleted manually, or the initial virtual machine needs to be modified, before the Storage Scale Base AMI is created. See the Amazon documentation ([Changing the Root Device Volume to Persist](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/RootDeviceStorage.html#Using_RootDeviceStorage)) for details. The procedure requires the [installation of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html). Follow the AWS documentation for the installation of the AWS CLI.

First step is to query the `InstanceId` and the setting for `DeleteOnTermination` of the running virtual machine:

```
SpectrumScaleVagrant\aws\prep-ami>aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=SpectrumScaleVagrant*" --query "Reservations[*].Instances[*].[InstanceId,BlockDeviceMappings[*]]"
[
    [
        [
            "i-0e8484f38bf860536",
            [
                {
                    "DeviceName": "/dev/sda1",
                    "Ebs": {
                        "AttachTime": "2019-02-21T20:37:36.000Z",
                        "DeleteOnTermination": false,
                        "Status": "attached",
                        "VolumeId": "vol-0219f2a207a60b7d8"
                    }
                }
            ]
        ]
    ]
]

SpectrumScaleVagrant\aws\prep-ami>
```

Next step is to modify the setting for `DeleteOnTermination` and to validate that the setting was changed:

```
SpectrumScaleVagrant\aws\prep-ami>aws ec2 modify-instance-attribute --instance-id "i-0dadfb6d892a0d83c" --region us-east-1 --block-device-mappings file://DeleteOnTermination.json

SpectrumScaleVagrant\aws\prep-ami>aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=SpectrumScaleVagrant*" --query "Reservations[*].Instances[*].[InstanceId,BlockDeviceMappings[*]]"
[
    [
        [
            "i-0e8484f38bf860536",
            [
                {
                    "DeviceName": "/dev/sda1",
                    "Ebs": {
                        "AttachTime": "2019-02-21T20:37:36.000Z",
                        "DeleteOnTermination": true,
                        "Status": "attached",
                        "VolumeId": "vol-0219f2a207a60b7d8"
                    }
                }
            ]
        ]
    ]
]

SpectrumScaleVagrant\aws\prep-ami>
```

## Appendix: Fix for vagrant-aws packaging

If `vagrant package` fails with the error message `Malformed => AMI names must be between 3 and 128 characters long, and may contain letters, numbers, '(', ')', '.', '-', '/' and '_'`
you need to apply a patch like the following to your local copy of vagrant-aws. You need to adopt to your installation path and user name:
```
--- /home/user/.vagrant.d/gems/2.7.0/gems/vagrant-aws-0.7.2/lib/vagrant-aws/action/package_instance.rb	2021-06-23 13:58:10.612642358 +0200
+++ /home/user/.vagrant.d/gems/2.7.0/gems/vagrant-aws-0.7.2/lib/vagrant-aws/action/package_instance_fixed.rb	2021-06-23 13:59:10.136684461 +0200
@@ -39,11 +39,12 @@
           begin
             # Get the Fog server object for given machine
             server = env[:aws_compute].servers.get(env[:machine].id)
+            servername = "#{server.tags["Name"]}".chomp!
 
             env[:ui].info(I18n.t("vagrant_aws.packaging_instance", :instance_id => server.id))
-            
+
             # Make the request to AWS to create an AMI from machine's instance
-            ami_response = server.service.create_image server.id, "#{server.tags["Name"]} Package - #{Time.now.strftime("%Y%m%d-%H%M%S")}", ""
+            ami_response = server.service.create_image server.id, "#{servername}-Package-#{Time.now.strftime("%Y%m%d-%H%M%S")}", ""
 
             # Find ami id
             @ami_id = ami_response.data[:body]["imageId"]
```
