# Spectrum Scale Vagrant
Example scripts and configuration files to install and configure IBM Spectrum Scale in a Vagrant environment.

## Installation

The scripts and configuration files provision a virtual Spectrum Scale cluster using Vagrant and VirtualBox.

### Install Vagrant and VirtualBox

Follow the [Vagrant Getting Started Guide](https://www.vagrantup.com/intro/getting-started/index.html) to install Vagrant and VirtualBox and to get familiar with Vagrant.

### Get the scripts and configuration files

Open a Command Prompt and clone the GitHub repostory:
1. `git clone https://github.com/IBM/SpectrumScaleVagrant.git`
1. `cd SpectrumScaleVagrant`

### Get the Spectrum Scale self-extracting installation package

The creation of the Spectrum Scale cluster requires the Spectrum Scale self-extracting installation package. The installation package can be downloaded from [IBM Support Fix Central](https://www.ibm.com/support/fixcentral/).

Download the `Spectrum_Scale_Data_Management-5.0.2.2-x86_64-Linux-install` package and save it to directory `SpectrumScaleVagrant\software` on the `host`.

Vagrant will copy this file during the provisioning from the `host` to directory `/software` on the management node `m1`.

### SpectrumScale_base.box - A Vagrant box optimized for Spectrum Scale

The virtual machines are based on the [official Vagrant CentOS/7 boxes](https://app.vagrantup.com/centos/boxes/7). Spectrum Scale requires a couple of additional RPMs. We create a custom Vagrant box to accelerate the provisioning of the virtual machines for the Spectrum Scale environment.

To create the custom Vagrant box:
1. `cd boxes`
1. `vagrant up`
1. `vagrant package SpectrumScale_base --output SpectrumScale_base.box`
1. `vagrant destroy`
1. `cd ..`

## Environments

This version of SpectrumScaleVagrant provides tooling to provision
* a single node Spectrum Scale cluster comprising one node only

It is planned to add configurations with multiple nodes later.

### Security

The environments are optimized to play with Spectrum Scale in a lab environment. To simplify access from the outside, all virtual nodes are configured with well known SSH keys. This is a security exposure for production environments.

### Single node cluster

The single node cluster is good enough for many lab exercises and for
developing and testing most of the scripts of this project.

The advantage of the single node cluster is that it is much faster provisioned
than a multi node cluster.

The scripts for the single node cluster are stored in `single`.

To create and logon on a single node cluster:
1. `cd single`
1. `vagrant up`
1. `vagrant ssh`

Configuration of Spectrum Scale Cluster:
```
[vagrant@m1 ~]$ sudo mmlscluster

GPFS cluster information
========================
  GPFS cluster name:         demo.example.com
  GPFS cluster id:           4200744107440960413
  GPFS UID domain:           demo.example.com
  Remote shell command:      /usr/bin/ssh
  Remote file copy command:  /usr/bin/scp
  Repository type:           CCR

 Node  Daemon node name  IP address  Admin node name  Designation
------------------------------------------------------------------
   1   m1.example.com    10.1.2.11   m1m.example.com  quorum-manager-perfmon

[vagrant@m1 ~]$
```
