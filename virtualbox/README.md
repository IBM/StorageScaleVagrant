# SpectrumScaleVagrant for VirtualBox

The scripts and files in this directory includes the tooling to provision and
configure the example Spectrum Scale cluster on VirtualBox.

## Install VirtualBox

After installing [SpectrumScaleVagrant and Vagrant itself](../README.md) you
need to install [VirtualBox](https://www.virtualbox.org/). The installation of
VirtualBox is straight forward. Just fullow the documentation.

## SpectrumScale_base.box - A Vagrant box optimized for Spectrum Scale

The virtual machines are based on the [official Vagrant CentOS/7 boxes](https://app.vagrantup.com/centos/boxes/7).
Spectrum Scale requires a couple of additional RPMs. We create a custom 
Spectrum Scale Vagrant box to accelerate the provisioning of the virtual
machines for the Spectrum Scale environment. The official CentOS box and the
additional RPMs will be downloaded during the provisioning process
(`vagrant up`).

To create the custom Vagrant box:
1. `cd SpectrumScaleVagrant\virtualbox\prep-box`
1. `vagrant up`
1. `vagrant package SpectrumScale_base --output SpectrumScale_base.box`
1. `vagrant destroy`
