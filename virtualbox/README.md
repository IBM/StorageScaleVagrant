# Storage Scale Vagrant for VirtualBox

The scripts and files in this directory include the tooling to provision and
configure the example Storage Scale cluster on VirtualBox.

## Install VirtualBox

In addition to [Storage Scale Vagrant and Vagrant itself](../README.md) you
need to install [VirtualBox](https://www.virtualbox.org/). The installation of
VirtualBox is straight forward. Just fullow the VirtualBox documentation.

## Security

Storage Scale Vagrant for VirtualBox is optimized to play with Storage Scale
in a lab environment. To simplify access from the outside, all virtual
nodes are configured with well known SSH keys. This is a security exposure
for production environments.

## SpectrumScale_base.box - A Vagrant box optimized for Storage Scale

The virtual machines are based on the [official Vagrant CentOS/8 boxes](https://app.vagrantup.com/centos/boxes/8).
Storage Scale requires a couple of additional RPMs. We create a custom 
Vagrant Storage Scale box to accelerate the provisioning of the virtual
machines for the Storage Scale environment. The official Vagrant CentOS box
and the additional CentOS RPMs will be downloaded during the provisioning
process (`vagrant up`).

To create the custom Vagrant Storage Scale box:
1. `cd SpectrumScaleVagrant\virtualbox\prep-box`
1. `vagrant up`
1. `vagrant package SpectrumScale_base --output SpectrumScale_base.box`
1. `vagrant destroy`

## Boot a virtual machine with a single node Storage Scale cluster

Now we are ready to boot a virtual machine on VirtualBox and to configure it with a single node Storage Scale cluster:
1. `cd SpectrumScaleVagrant\virtualbox`
1. `vagrant up`
1. `vagrant ssh`

See the [README.md](../README.md) for details on the configured Storage Scale
cluster.
