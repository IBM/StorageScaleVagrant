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

To explore the Spectrum Scale REST API, enter `https://localhost:8888/ibm/api/explorer/#/` in a browser. The Spectrum Scale REST API uses the same accounts as the Spectrum Scale GUI. There's also a blog post available which contains more details on how to explore the REST API using the IBM API Explorer URL:

[Trying out and exploring the Spectrum Scale REST API using “curl” and/or the IBM API Explorer website](https://developer.ibm.com/storage/2019/02/06/trying-out-and-exploring-the-spectrum-scale-rest-api/)

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

## Spectrum Scale Filesystem

Spectrum Scale Vagrant configures the filesystem `fs1` and adds some example data to illustrate selected Spectrum Scale features.

### Filesystems

The filesystem `fs1` mounts on all cluster nodes at `/ibm/fs1`:
```
[vagrant@m1 ~]$ mmlsmount all
File system fs1 is mounted on 1 nodes.

[vagrant@m1 ~]$ mmlsfs fs1 -T
flag                value                    description
------------------- ------------------------ -----------------------------------
 -T                 /ibm/fs1                 Default mount point

[vagrant@m1 ~]$
```

In Linux, a Spectrum Scale filesystem can be used like any other filesystem:
```
[vagrant@m1 ~]$ mount | grep /ibm/
fs1 on /ibm/fs1 type gpfs (rw,relatime,seclabel)

[vagrant@m1 ~]$ find /ibm/
/ibm/
/ibm/fs1
/ibm/fs1/.snapshots

[vagrant@m1 ~]$
```

REST API call to show all filesystems:

```
[vagrant@m1 ~]$ curl -k -s -S -X GET --header 'Accept: application/json' -u admin:admin001 'https://localhost/scalemgmt/v2/filesystems/'
{
  "filesystems" : [ {
    "name" : "fs1"
  } ],
  "status" : {
    "code" : 200,
    "message" : "The request finished successfully."
  }
}[vagrant@m1 ~]$
```

### Storage Pools

Storage pools allow to integrate different media types such es NVMe, SSD and NL-SAS into a single filesystem. Each Spectrum Scale filesystem has at list the system pool which stores metadata (inodes) and optionally data (content of files).

```
[vagrant@m1 ~]$ mmlspool fs1
Storage pools in file system at '/ibm/fs1':
Name                    Id   BlkSize Data Meta Total Data in (KB)   Free Data in (KB)   Total Meta in (KB)    Free Meta in (KB)
system                   0      4 MB  yes  yes        5242880        1114112 ( 21%)        5242880        1167360 ( 22%)

[vagrant@m1 ~]$ mmdf fs1
disk                disk size  failure holds    holds           free in KB          free in KB
name                    in KB    group metadata data        in full blocks        in fragments
--------------- ------------- -------- -------- ----- -------------------- -------------------
Disks in storage pool: system (Maximum disk size allowed is 15.87 GB)
nsd3                  1048576        1 Yes      Yes          229376 ( 22%)         11384 ( 1%)
nsd4                  1048576        1 Yes      Yes          204800 ( 20%)         11128 ( 1%)
nsd5                  1048576        1 Yes      Yes          217088 ( 21%)         11128 ( 1%)
nsd2                  1048576        1 Yes      Yes          225280 ( 21%)         11640 ( 1%)
nsd1                  1048576        1 Yes      Yes          237568 ( 23%)         11640 ( 1%)
                -------------                         -------------------- -------------------
(pool total)          5242880                               1114112 ( 21%)         56920 ( 1%)

                =============                         ==================== ===================
(total)               5242880                               1114112 ( 21%)         56920 ( 1%)

Inode Information
-----------------
Number of used inodes:            4108
Number of free inodes:          103412
Number of allocated inodes:     107520
Maximum number of inodes:       107520

[vagrant@m1 ~]$
```

A typcial configuration is to use NVMe or SSD for the system pool for metadata and hot files, and to add a second storage pool with NL-SAS for colder data.
```
[vagrant@m1 ~]$ cat /vagrant/files/spectrumscale/stanza-fs1-capacity
%nsd: device=/dev/sdg
nsd=nsd6
servers=m1
usage=dataOnly
failureGroup=1
pool=capacity

%nsd: device=/dev/sdh
nsd=nsd7
servers=m1
usage=dataOnly
failureGroup=1
pool=capacity

[vagrant@m1 ~]$ sudo mmadddisk fs1 -F /vagrant/files/spectrumscale/stanza-fs1-capacity

The following disks of fs1 will be formatted on node m1:
    nsd6: size 10240 MB
    nsd7: size 10240 MB
Extending Allocation Map
Creating Allocation Map for storage pool capacity
Flushing Allocation Map for storage pool capacity
Disks up to size 322.37 GB can be added to storage pool capacity.
Checking Allocation Map for storage pool capacity
Completed adding disks to file system fs1.
mmadddisk: mmsdrfs propagation completed.

[vagrant@m1 ~]$
```

Now the filesystem has two storage pool.

```
[vagrant@m1 ~]$ mmlspool fs1
Storage pools in file system at '/ibm/fs1':
Name                    Id   BlkSize Data Meta Total Data in (KB)   Free Data in (KB)   Total Meta in (KB)    Free Meta in (KB)
system                   0      4 MB  yes  yes        5242880        1101824 ( 21%)        5242880        1155072 ( 22%)
capacity             65537      4 MB  yes   no       20971520       20824064 ( 99%)              0              0 (  0%)

[vagrant@m1 ~]$ mmdf fs1
disk                disk size  failure holds    holds           free in KB          free in KB
name                    in KB    group metadata data        in full blocks        in fragments
--------------- ------------- -------- -------- ----- -------------------- -------------------
Disks in storage pool: system (Maximum disk size allowed is 15.87 GB)
nsd1                  1048576        1 Yes      Yes          233472 ( 22%)         11640 ( 1%)
nsd2                  1048576        1 Yes      Yes          221184 ( 21%)         11640 ( 1%)
nsd3                  1048576        1 Yes      Yes          229376 ( 22%)         11384 ( 1%)
nsd4                  1048576        1 Yes      Yes          204800 ( 20%)         11128 ( 1%)
nsd5                  1048576        1 Yes      Yes          212992 ( 20%)         11128 ( 1%)
                -------------                         -------------------- -------------------
(pool total)          5242880                               1101824 ( 21%)         56920 ( 1%)

Disks in storage pool: capacity (Maximum disk size allowed is 322.37 GB)
nsd6                 10485760        1 No       Yes        10412032 ( 99%)          8056 ( 0%)
nsd7                 10485760        1 No       Yes        10412032 ( 99%)          8056 ( 0%)
                -------------                         -------------------- -------------------
(pool total)         20971520                              20824064 ( 99%)         16112 ( 0%)

                =============                         ==================== ===================
(data)               26214400                              21925888 ( 84%)         73032 ( 0%)
(metadata)            5242880                               1101824 ( 21%)         56920 ( 1%)
                =============                         ==================== ===================
(total)              26214400                              21925888 ( 84%)         73032 ( 0%)

Inode Information
-----------------
Number of used inodes:            4108
Number of free inodes:          103412
Number of allocated inodes:     107520
Maximum number of inodes:       107520

[vagrant@m1 ~]$
```
