# SpectrumScaleVagrant for AWS

The scripts and files in this directory includes the tooling to provision and
configure the example Spectrum Scale cluster on AWS.

## Install the Vagrant plugin for AWS (vagrant-aws)

After installing [SpectrumScaleVagrant and Vagrant itself](../README.md) you
need to install the [vagrant-aws plugin](https://github.com/mitchellh/vagrant-aws)
to enable Vagrant to manage virtual environments on AWS.

On my host the installation of the vagrant-aws plugin failed, but [pinning the
version of the fog-ovirt](https://github.com/mitchellh/vagrant-aws/issues/539#issuecomment-398100794)
resolved the issue:

```
vagrant plugin install --plugin-version 1.0.1 fog-ovirt
vagrant plugin install vagrant-aws
```
