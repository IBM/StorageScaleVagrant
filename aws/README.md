# SpectrumScaleVagrant for AWS

The scripts and files in this directory includes the tooling to provision and
configure the example Spectrum Scale cluster on AWS.

## Install the Vagrant plugin for AWS (vagrant-aws)

After installing [SpectrumScaleVagrant and Vagrant itself](../README.md) you
need to install the [vagrant-aws plugin](https://github.com/mitchellh/vagrant-aws)
to enable Vagrant to manage virtual environments on AWS.

On my host the installation of the vagrant-aws plugin failed, but [pinning the
version of fog-ovirt](https://github.com/mitchellh/vagrant-aws/issues/539#issuecomment-398100794)
resolved the issue:

```
vagrant plugin install --plugin-version 1.0.1 fog-ovirt
vagrant plugin install vagrant-aws
```

## Get the dummy box for the vagrant-aws plugin

Vagrant requires each provider plug-in to provide its own box format. The
vagrant-aws plugin provides a [dummy box](https://github.com/mitchellh/vagrant-aws#box-format)
to get the plugin going. In contrast to other box formats this box format does
not include images of virtual machines, but a reference to an Amazon AMI stored
on AWS.

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
but before using CentOS you need to find [CentOS 7 on the AWS marketplace](https://aws.amazon.com/marketplace/pp/B00O7WM7QW)
and to subscribe it in order to accept the license agreement.

## Decide on how to integrate the Spectrum Scale self-extracting installation package

Depending on your network connectivity, it takes some time to upload the Spectrum Scale self-extracting installation package into AWS. There are two approach options to optimize the creation of the AWS AMI image for Spectrum Scale:
1. Save the self-extracting installation package to `SpectrumScaleVagrant\software` before you to boot the virtual machine from which you create the Spectrum Scale AWS AMI. Then Vagrant will automatically copy it from your host to the virtual machine in AWS.
1. Copy the self-extracting installation package to `/software` of your virtual machine, after you have booted it. This approach is faster, if you have a copy for instance in an S3 bucket.

## Spectrum Scale Base AMI - An AWS AMI optimized for Spectrum Scale

The virtual machines are based on the official CentOS/7 AWS AMI. Spectrum Scale requires a couple of additional RPMs. We create a custom Spectrum Scale Base AMI to accelerate the provisioning of the virtual machines for the Spectrum Scale environment.

To start the initial virtual machine:
1. `cd SpectrumScaleVagrant\aws\prep-ami`
1. `Vagrant up`
1. `Vagrant ssh`

Copy the Spectrum Scale self-extracting installation package to `/software`, if you decided for approach option 2 above.

```
SpectrumScaleVagrant\aws\prep-ami>vagrant ssh

[centos@ip-172-31-27-143 ~]$ ls -l /software
total 1489140
-rw-r--r--. 1 centos centos        136 Feb 16 17:26 README
-rw-rw-r--. 1 centos centos 1564495872 Feb 14 13:20 Spectrum_Scale_Data_Management-5.0.2.2-x86_64-Linux-install

[centos@ip-172-31-27-143 ~]$ exit
logout
Connection to ec2-34-224-86-55.compute-1.amazonaws.com closed.

SpectrumScaleVagrant\aws\prep-ami>
```

By default the CentOS AMI leaves the orphaned root volume, after the owning virtual machine (instance) is terminated. Amazon charges for orphaned root volumes. They either need to be deleted manually, or the initial virtual machine needs to be modified, before the Spectrum Scale Base AMI is created. See the Amazon documentation ([Changing the Root Device Volume to Persist](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/RootDeviceStorage.html#Using_RootDeviceStorage)) for details. The procedure requires the [installation of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

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

Having checked that `DeleteOnTermination` is set to `true` we can build the Spectrum Scale AWS AMI and terminate the virtual machine:
1. `vagrant package SpectrumScale_base --output SpectrumScale_base.box`
1. `vagrant destroy`

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
