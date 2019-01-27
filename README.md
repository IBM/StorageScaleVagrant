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

## Configurations

This version of SpectrumScaleVagrant provides tooling to provision
* a single node Spectrum Scale cluster comprising one node only

It is planned to add configurations with multiple nodes later.

### Single node cluster

The single node cluster is good enough for many lab excercises and for
developing and testing most of the scripts of this project.

The advantage of the single node cluster is that it is much faster provisioned
than a multi node cluster.

The scripts for the single node cluster are stored in `single`.

To create and logon on a single node cluster:
1. `cd single`
1. `vagrant up`
1. `vagrant ssh`
