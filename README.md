# Spectrum Scale Vagrant
Example scripts and configuration files to install and configure IBM Spectrum Scale in a Vagrant environment.

## Installation

The scripts and configuration files provision a virtual Spectrum Scale cluster using Vagrant and VirtualBox.

### Install Vagrant and VirtualBox

Follow the [Vagrant Getting Started Guide](https://www.vagrantup.com/intro/getting-started/index.html) to install Vagrant and VirtualBox and to get familiar with Vagrant.

### Get the scripts and configuration files

Open a Command Prompt and clone the GitHub repository:
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

### Spectrum Scale GUI

To connect to the Spectrum Scale GUI, enter `https://localhost:8888` in a browser. The GUI is configured with a self-signed certificate. The login screen shows, after accepting the certificate. The user `admin` has the default password `admin001`.

![](/doc/gui/gui_login.png)

Cluster overview in Spectrum Scale GUI:

![](/doc/gui/gui_home_overview.png)

### Spectrum Scale REST API

To explore the Spectrum Scale REST API, enter `https://localhost:8888/ibm/api/explorer/#/` in a browser. The Spectrum Scale REST API uses the same accounts as the Spectrum Scale GUI.

![](/doc/gui/gui_rest_api.png)

Configuration of Spectrum Scale Cluster:

```
[vagrant@m1 ~]$ curl -k -X GET --header 'Accept: application/json' -u admin:admin001 'https://localhost/scalemgmt/v2/clu
ster'
{
  "cluster" : {
    "clusterSummary" : {
      "clusterId" : 4200744107441232322,
      "clusterName" : "demo.example.com",
      "primaryServer" : "m1.example.com",
      "rcpPath" : "/usr/bin/scp",
      "rcpSudoWrapper" : false,
      "repositoryType" : "CCR",
      "rshPath" : "/usr/bin/ssh",
      "rshSudoWrapper" : false,
      "uidDomain" : "demo.example.com"
    }
  },
  "status" : {
    "code" : 200,
    "message" : "The request finished successfully."
  }
}

[vagrant@m1 ~]$
```

Cluster nodes:

```
[vagrant@m1 ~]$ curl -k -X GET --header 'Accept: application/json' -u admin:admin001 'https://localhost/scalemgmt/v2/nod
es'
{
  "nodes" : [ {
    "adminNodeName" : "m1.example.com"
  } ],
  "status" : {
    "code" : 200,
    "message" : "The request finished successfully."
  }
}

[vagrant@m1 ~]$
```

### Filesystem

For all clusters, the Spectrum Scale filesystem `fs1` is created which is mounted at `/ibm/fs1`:
```
[vagrant@m1 ~]$ sudo mmlsmount all
File system fs1 is mounted on 1 nodes.

[vagrant@m1 ~]$ mount | grep fs1
fs1 on /ibm/fs1 type gpfs (rw,relatime,seclabel)

[vagrant@m1 ~]$ ls -la /ibm/fs1/
total 261
drwxr-xr-x. 2 root root 262144 Feb  2 10:50 .
drwxr-xr-x. 3 root root   4096 Feb  2 10:50 ..
dr-xr-xr-x. 2 root root   8192 Jan  1  1970 .snapshots

[vagrant@m1 ~]$
```

The filesystem `fs1` is configured with two storage pools to illustrate how to integrate storage media such as NVMe, SSD and NL-SAS in a single filesystem.

```
[vagrant@m1 ~]$ sudo mmlspool fs1
Storage pools in file system at '/ibm/fs1':
Name                    Id   BlkSize Data Meta Total Data in (KB)   Free Data in (KB)   Total Meta in (KB)    Free Meta in (KB)
system                   0      4 MB  yes  yes        5242880        1118208 ( 21%)        5242880        1171456 ( 22%)
capacity             65537      4 MB  yes   no       20971520       20824064 ( 99%)              0              0 (  0%)
```

The capacity of each storage pool and therefore the capacity of a filesystem is provided by one or more disks.

```
[vagrant@m1 ~]$ sudo mmlsdisk fs1
disk         driver   sector     failure holds    holds                            storage
name         type       size       group metadata data  status        availability pool
------------ -------- ------ ----------- -------- ----- ------------- ------------ ------------
nsd1         nsd         512           1 Yes      Yes   ready         up           system
nsd2         nsd         512           1 Yes      Yes   ready         up           system
nsd3         nsd         512           1 Yes      Yes   ready         up           system
nsd4         nsd         512           1 Yes      Yes   ready         up           system
nsd5         nsd         512           1 Yes      Yes   ready         up           system
nsd6         nsd         512           1 No       Yes   ready         up           capacity
nsd7         nsd         512           1 No       Yes   ready         up           capacity

[vagrant@m1 ~]$
```
