# SpectrumScaleVagrant for KVM/libvirt

The scripts and files in this directory include the tooling to provision and
configure the example Spectrum Scale cluster on KVM/libvirt.

## Install KVM/libvirt.

In addition to [SpectrumScaleVagrant and Vagrant itself](../README.md) you
need to install KVM/libvirt. Just fullow the KVM/libvirt documentation.

## Security

SpectrumScaleVagrant for KVM/libvirt is optimized to play with Spectrum Scale
in a lab environment. To simplify access from the outside, all virtual
nodes are configured with well known SSH keys. This is a security exposure
for production environments.

## SpectrumScale_base.box - A Vagrant box optimized for Spectrum Scale

The virtual machines are based on the [official Vagrant CentOS/8 boxes](https://app.vagrantup.com/centos/boxes/8).
Spectrum Scale requires a couple of additional RPMs. We create a custom
Vagrant Spectrum Scale box to accelerate the provisioning of the virtual
machines for the Spectrum Scale environment. The official Vagrant CentOS box
and the additional CentOS RPMs will be downloaded during the provisioning
process (`vagrant up`).

To create the custom Vagrant Spectrum Scale box:
1. `cd SpectrumScaleVagrant\libvirt\prep-box`
2. `vagrant up`
3. `vagrant package SpectrumScale_base --output SpectrumScale_base.box`
4. `vagrant box add SpectrumScale_base.box --name SpectrumScale_base`
5. `vagrant destroy`

## Boot a virtual machine with a single node Spectrum Scale cluster

Now we are ready to boot a virtual machine on libvirt and to configure it with a single node Spectrum Scale cluster:
1. `cd SpectrumScaleVagrant\libvirt`
2. `vagrant up`
3. `vagrant ssh`

See the [README.md](../README.md) for details on the configured Spectrum Scale
cluster.
