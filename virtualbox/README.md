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

## StorageScale_base.box - A Vagrant box optimized for Storage Scale

The virtual machines are based on the [official Vagrant CentOS/8 boxes](https://app.vagrantup.com/centos/boxes/8).
Storage Scale requires a couple of additional RPMs. We create a custom 
Vagrant Storage Scale box to accelerate the provisioning of the virtual
machines for the Storage Scale environment. The official Vagrant CentOS box
and the additional CentOS RPMs will be downloaded during the provisioning
process (`vagrant up`).

To create the custom Vagrant Storage Scale box:

1. `cd StorageScaleVagrant\virtualbox\prep-box`
1. `vagrant up`
1. `vagrant package StorageScale_base --output StorageScale_base.box`
1. `vagrant destroy`

## Boot a virtual machine with a single node Storage Scale cluster

Now we are ready to boot a virtual machine on VirtualBox and to configure it with a single node Storage Scale cluster:

1. `cd StorageScaleVagrant\virtualbox`
1. `vagrant up`
1. `vagrant ssh`

## Shut down and restart the virtual machine

To shut down (gracefully) and re-start the virtual machine, please use the following command sequence:

1. `vagrant halt`
1. `vagrant reload`

Trying to re-start the VM using `vagrant up` will throw an error that the storage controller already exists.

See the [README.md](../README.md) for details on the configured Storage Scale
cluster.
