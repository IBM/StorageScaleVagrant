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

## Install the Vagrant plugin for AWS (vagrant-aws)

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
