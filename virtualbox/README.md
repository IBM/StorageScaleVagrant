# SpectrumScaleVagrant for VirtualBox

The scripts and files in this directory include the tooling to provision and
configure the example Spectrum Scale cluster on VirtualBox.

## Install VirtualBox

In addition to [SpectrumScaleVagrant and Vagrant itself](../README.md) you
need to install [VirtualBox](https://www.virtualbox.org/). The installation of
VirtualBox is straight forward. Just fullow the VirtualBox documentation.

## Security

SpectrumScaleVagrant for VirtualBox is optimized to play with Spectrum Scale
in a lab environment. To simplify access from the outside, all virtual
nodes are configured with well known SSH keys. This is a security exposure
for production environments.

## SpectrumScale_base.box - A Vagrant box optimized for Spectrum Scale

The virtual machines are based on the [official Vagrant CentOS/7 boxes](https://app.vagrantup.com/centos/boxes/7).
Spectrum Scale requires a couple of additional RPMs. We create a custom 
Vagrant Spectrum Scale box to accelerate the provisioning of the virtual
machines for the Spectrum Scale environment. The official Vagrant CentOS box
and the additional CentOS RPMs will be downloaded during the provisioning
process (`vagrant up`).

To create the custom Vagrant Spectrum Scale box:
1. `cd SpectrumScaleVagrant\virtualbox\prep-box`
1. `vagrant up`
1. `vagrant package SpectrumScale_base --output SpectrumScale_base.box`
1. `vagrant destroy`

## Boot a virtual machine with a single node Spectrum Scale cluster

Now we are ready to boot a virtual machine on VirtualBox and to configure it with a single node Spectrum Scale cluster:
1. `cd SpectrumScaleVagrant\virtualbox`
1. `vagrant up`
1. `vagrant ssh`

See the [README.md](../README.md) for details on the configured Spectrum Scale
cluster.
