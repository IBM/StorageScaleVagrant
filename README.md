# Storage Scale Vagrant

Example scripts and configuration files to install and configure IBM Storage Scale in a Vagrant environment.

## Installation

The scripts and configuration files provision a single node IBM Storage Scale cluster using Vagrant.

### Get the scripts and configuration files from GitHub

Open a Command Prompt and clone the GitHub repository:
1. `git clone https://github.com/IBM/SpectrumScaleVagrant.git`
1. `cd SpectrumScaleVagrant`

### Get the Storage Scale self-extracting installation package

The creation of the Storage Scale cluster requires the Storage Scale
self-extracting installation package. The developer edition can be downloaded
from the [Storage Scale home page](https://www.ibm.com/products/storage-scale).

Download the `Spectrum_Scale_Developer-5.1.7.0-x86_64-Linux-install` package and
save it to directory `SpectrumScaleVagrant/software` on the `host`.

Please note that in case the Storage Scale Developer version you downloaded is
newer than the one we listed here, you still might want to use the new
version. You need to update the `$SpectrumScale_version` variable in
[Vagrantfile.common](shared/Vagrantfile.common) to match the version you
downloaded before continuing.

Vagrant will copy this file during the provisioning from the `host` to directory
`/software` on the management node `m1`.

### Install Vagrant

Follow the [Vagrant Getting Started
Guide](https://learn.hashicorp.com/tutorials/vagrant/getting-started-index) to
install Vagrant to get familiar with Vagrant.


## Provisioning

Storage Scale Vagrant supports the creation of a single node Storage Scale
cluster on VirtualBox, libvirt and on AWS. There is a subdirectory for each
supported provider. Follow the instructions in the subdirectory of your
preferred provider to install and configure a virtual machine.

| Directory                  | Provider            |
|----------------------------|---------------------|
| [aws](./aws)               | Amazon Web Services |
| [virtualbox](./virtualbox) | VirtualBox          |
| [libvirt](./libvirt)       | libvirt (KVM/QEMU)  |


Please note that for AWS you might want to prefer the new "Cloudkit" Storage
Scale capability that is also available with the Storage Scale Developer Edition.
For more details about Cloudkit, please refer to the [documentation](https://www.ibm.com/docs/en/spectrum-scale/5.1.7?topic=reference-cloudkit).

Once the virtual environment is provided, Storage Scale Vagrant uses the same
scripts to install and configure Storage Scale. Storage Scale Vagrant executes
those scripts automatically during the provisioning process (`vagrant up`) for
your preferred provider.

| Directory                        | Description                                                         |
|----------------------------------|---------------------------------------------------------------------|
| [setup/install](./setup/install) | Perform all steps to provision a Storage Scale cluster             |
| [setup/demo](./setup/demo)       | Perform all steps to configure the Storage Scale for demo purposes |


## Storage Scale Management Interfaces

Storage Scale Vagrant uses the Storage Scale CLI and the Storage Scale REST API
to install and configure Storage Scale. In addition it configures the Storage
Scale GUI to allow interested users to explore its capabilities.

### Storage Scale CLI

Storage Scale Vagrant configures the shell `$PATH` variable and the sudo
`secure_path` to include the location of the Storage Scale executables.

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

### Storage Scale REST API

To explore the Storage Scale REST API, enter
`https://localhost:8888/ibm/api/explorer` (for AWS please use `https://>AWS Public IP>/ibm/api/explorer`)
in a browser. The Storage Scale REST API uses the
same accounts as the Storage Scale GUI. There's also a blog post available which
contains more details on how to explore the REST API using the IBM API Explorer
URL:

[Trying out and exploring the Storage Scale REST API using “curl” and/or the IBM API Explorer website](https://community.ibm.com/community/user/storage/blogs/andreas-kninger1/2019/02/06/trying-out-and-exploring-the-spectrum-scale-rest-api-using-curl-andor-the-ibm-api-explorer-website)

![](/doc/gui/gui_rest_api.png)

Configuration of Storage Scale Cluster:

```
[vagrant@m1 ~]$ curl -k -X GET --header 'Accept: application/json' -u admin:admin001 'https://localhost:8888/scalemgmt/v2/cluster'
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
  .....
  "status" : {
    "code" : 200,
    "message" : "The request finished successfully."
  }
}

[vagrant@m1 ~]$
```

Cluster nodes:

```
[vagrant@m1 ~]$ curl -k -X GET --header 'Accept: application/json' -u admin:admin001 'https://localhost:8888/scalemgmt/v2/nodes'
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

### Storage Scale GUI

To connect to the Storage Scale GUI, enter `https://localhost:8888` (AWS:
`https://<AWS Public IP>`) in a browser. The GUI is configured with a
self-signed certificate. The login screen shows, after accepting the
certificate. The user `admin` has the default password `admin001`.

![](/doc/gui/gui_login.png)

Cluster overview in Storage Scale GUI:

![](/doc/gui/gui_home_overview.png)


## Storage Scale Filesystem

Storage Scale Vagrant configures the filesystem `fs1` and adds some example data
to illustrate selected Storage Scale features.

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

On Linux, a Storage Scale filesystem can be used like any other filesystem:

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

Storage pools allow to integrate different media types such es NVMe, SSD and
NL-SAS into a single filesystem. Each Storage Scale filesystem has at list the
system pool which stores metadata (inodes) and optionally data (content of
files).

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

A typical configuration is to use NVMe or SSD for the system pool for metadata
and hot files, and to add a second storage pool with NL-SAS for colder data.

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

## Disclaimer

**Please note:** This project is released for use "AS IS" without any warranties of any kind, including, but not limited to installation, use, or performance of the resources in this repository.
We are not responsible for any damage, data loss or charges incurred with their use.
This project is outside the scope of the IBM PMR process. If you have any issues, questions or suggestions you can create a new issue [here](https://github.com/IBM/SpectrumScaleVagrant/issues).
Issues will be addressed as team availability permits.
