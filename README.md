# Storage Scale Vagrant

Example scripts and configuration files to install and configure IBM Storage Scale in a Vagrant environment.

## Installation

The scripts and configuration files provision a single node IBM Storage Scale cluster using Vagrant.

### Get the scripts and configuration files from GitHub

Open a Command Prompt and clone the GitHub repository:

1. `git clone https://github.com/IBM/StorageScaleVagrant.git`
1. `cd StorageScaleVagrant`

### Get the Storage Scale self-extracting installation package

The creation of the Storage Scale cluster requires the Storage Scale
self-extracting installation package. The developer edition can be downloaded
from the [Storage Scale home page](https://www.ibm.com/products/storage-scale).

Extract the `Storage_Scale_Developer-6.0.0.2-x86_64-Linux-install` package and
save it to directory `StorageScaleVagrant/software` on the `host`.

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
For more details about Cloudkit, please refer to the [documentation](https://www.ibm.com/docs/en/storage-scale/6.0.0?topic=reference-cloudkit).

Once the virtual environment is provided, Storage Scale Vagrant uses the same
scripts to install and configure Storage Scale. Storage Scale Vagrant executes
those scripts automatically during the provisioning process (`vagrant up`) for
your preferred provider.

| Directory                        | Description                                                         |
|----------------------------------|---------------------------------------------------------------------|
| [setup/install](./setup/install) | Perform all steps to provision a Storage Scale cluster              |
| [setup/demo](./setup/demo)       | Perform all steps to configure the Storage Scale for demo purposes  |

## Storage Scale Management Interfaces

Storage Scale Vagrant uses the Storage Scale CLI and the Storage Scale REST API
to install and configure Storage Scale. In addition it configures the Storage
Scale GUI to allow interested users to explore its capabilities.

[!IMPORTANT]
As per default setting, the Storage Scale GUI is mapped to port 8888 on the host.
That might conflict with other software using that port (see issue #54).
You can configure the port yourself [here](https://github.com/IBM/StorageScaleVagrant/blob/main/virtualbox/Vagrantfile#L58)
for VirtualBox and [here](https://github.com/IBM/StorageScaleVagrant/blob/main/libvirt/Vagrantfile#L62) for libvirt.

### Storage Scale CLI

Storage Scale Vagrant configures the shell `$PATH` variable and the sudo
`secure_path` to include the location of the Storage Scale executables.

```shell
[vagrant@m1 ~]$ sudo mmlscluster

GPFS cluster information
========================
  GPFS cluster name:         demo
  GPFS cluster id:           4200744107666200101
  GPFS UID domain:           demo
  Remote shell command:      /usr/lpp/mmfs/bin/scaleadmremoteexecute
  Remote file copy command:  /usr/lpp/mmfs/bin/scaleadmremotetransfer
  Repository type:           CCR

 Node  Daemon node name  IP address  Admin node name  Designation
------------------------------------------------------------------
   1   m1.example.com    10.1.2.11   m1.example.com   quorum-manager-perfmon

[vagrant@m1 ~]$
```

### Storage Scale REST API

To explore the Storage Scale REST API v3, enter `https://192.168.56.101/openapi`
in a browser.

![GUI showing REST API](/doc/gui/gui_rest_api.png)

As an example, get the configuration of the Storage Scale Cluster and the list
of nodes:

```shell
[vagrant@m1 ~]$ curl -k -X 'GET' \
  'https://192.168.56.101:46443/scalemgmt/v3/clusters?view=BASIC' \
  -H 'accept: application/json' \
  -u admin:supersecret
{
  "clusters":  [
    {
      "cluster_name":  "demo",
      "domain_name":  "demo",
      "remote_file_copy_cmd":  "/usr/lpp/mmfs/bin/scaleadmremotetransfer",
      "remote_shell_cmd":  "/usr/lpp/mmfs/bin/scaleadmremoteexecute",
      "cluster_id":  "4200744107666200101",
      "repository_type":  "CCR",
      "nodes":  [
        {
          "node_name":  "m1.example.com",
          "admin_node_name":  "m1.example.com",
          "node_designations":  [
            "quorum",
            "manager",
            "perfmon",
            "ces"
          ],
          "node_number":  "1",
          "daemon_ip_address":  "10.1.2.11"
        }
      ],
      "manager":  "m1"
    }
  ]
}[vagrant@m1 ~]$
```

### Storage Scale GUI

To connect to the Storage Scale GUI, enter `https://localhost:8888` (AWS:
`https://<AWS Public IP>`) in a browser. The GUI is configured with a
self-signed certificate. The login screen shows, after accepting the
certificate. The user `admin` has the default password `admin001`.
To be able to use the GUI early in the installation process, a user
`performance` with the default password `monitor` is created.

![GUI Login](/doc/gui/gui_login.png)

Cluster overview in Storage Scale GUI:

![GUI Cluster Overview](/doc/gui/gui_home_overview.png)

## Storage Scale Filesystem

Storage Scale Vagrant configures the filesystem `fs1` and adds some example data
to illustrate selected Storage Scale features.

### Filesystems

The filesystem `fs1` mounts on all cluster nodes at `/ibm/fs1`:

```shell
[vagrant@m1 ~]$ mmlsmount all
File system fs1 is mounted on 1 nodes.

[vagrant@m1 ~]$ mmlsfs fs1 -T
flag                value                    description
------------------- ------------------------ -----------------------------------
 -T                 /ibm/fs1                 Default mount point

[vagrant@m1 ~]$
```

On Linux, a Storage Scale filesystem can be used like any other filesystem:

```shell
[vagrant@m1 ~]$ mount | grep /ibm/
fs1 on /ibm/fs1 type gpfs (rw,relatime,seclabel)

[vagrant@m1 ~]$ find /ibm/
/ibm/
/ibm/fs1
/ibm/fs1/.snapshots

[vagrant@m1 ~]$
```

REST API call to show all filesystems:

```shell
[vagrant@m1 ~]$ curl -k -X 'GET' \
  'https://192.168.56.101:46443/scalemgmt/v3/filesystems' \
  -H 'accept: application/json' \
  -u admin:supersecret
{
  "filesystems":  [
    {
      "name":  "cesShared",
      "uid":  "0B02010A:69C25683",
      "min_fragment_size":  8192,
      "inode_size":  4096,
      "indirect_block_size":  32768,
      "default_metadata_replicas":  1,
      "max_metadata_replicas":  2,
      "default_data_replicas":  1,
      "max_data_replicas":  2,
      "block_allocation_type":  "CLUSTER_BLOCKALLOCATIONTYPE",
      "file_locking_semantics":  "NFS4_FILELOCKINGSEMANTICS",
      "acl_semantics":  "ALL_ACLSEMANTICS",
      "num_nodes":  1,
      "block_size":  4194304,
      "quotas_accounting_enabled":  "none",
      "quotas_enforced":  "none",
      "default_quotas_enabled":  "none",
      "perfileset_quotas":  "NO",
      "filesetdf_enabled":  "NO",
      "create_time":  "2026-03-24T09:16:51Z",
      "dmapi_enabled":  "NO",
      "logfile_size":  "33554432",
      "exact_mtime":  "YES",
      "suppress_atime":  "RELATIME_SUPPRESSATIME",
      "strict_replication":  "WHEN_POSSIBLE_STRICT_REPL",
      "fast_ea_enabled":  "yes",
      "encryption":  "NO",
      "inode_limit":  "67584",
      "max_snapshot_id":  0,
      "log_replicas":  0,
      "is_4K_aligned":  "YES",
      "rapid_repair_enabled":  "YES",
      "subblocks_per_full_block":  512,
      "storage_pools":  [
        {
          "name":  "system"
        }
      ],
      "file_audit_log":  "NO",
      "maintenance_mode":  "NO_MAINTENANCEMODE",
      "flush_on_close":  "NO",
      "auto_inode_limit":  "NO",
      "disks":  [
        {
          "name":  "nsd4"
        },
        {
          "name":  "nsd5"
        }
      ],
      "automatic_mount_option":  "YES_AUTO",
      "default_mount_point":  "/ibm/cesShared",
      "mount_priority":  0,
      "nfs4_owner_write_acl":  "YES",
      "domain_id":  0,
      "manager":  "m1",
      "inode_segment_manager":  "YES",
      "cluster":  "demo",
      "local_version":  "38.00 (6.0.0.0)",
      "original_version":  "38.00 (6.0.0.0)",
      "manager_version":  "38.00 (6.0.0.0)",
      "highest_supported_version":  "38.00 (6.0.0.0)",
      "acldata_maxlen":  "ACLDATAMAXLEN_15"
    },
    {
      "name":  "fs1",
      "uid":  "0B02010A:69C2567E",
      "min_fragment_size":  8192,
      "inode_size":  4096,
      "indirect_block_size":  32768,
      "default_metadata_replicas":  1,
      "max_metadata_replicas":  2,
      "default_data_replicas":  1,
      "max_data_replicas":  2,
      "block_allocation_type":  "CLUSTER_BLOCKALLOCATIONTYPE",
      "file_locking_semantics":  "NFS4_FILELOCKINGSEMANTICS",
      "acl_semantics":  "ALL_ACLSEMANTICS",
      "num_nodes":  1,
      "block_size":  4194304,
      "quotas_accounting_enabled":  "user;group;fileset",
      "quotas_enforced":  "user;group;fileset",
      "default_quotas_enabled":  "none",
      "perfileset_quotas":  "NO",
      "filesetdf_enabled":  "NO",
      "create_time":  "2026-03-24T09:16:46Z",
      "dmapi_enabled":  "NO",
      "logfile_size":  "33554432",
      "exact_mtime":  "YES",
      "suppress_atime":  "RELATIME_SUPPRESSATIME",
      "strict_replication":  "WHEN_POSSIBLE_STRICT_REPL",
      "fast_ea_enabled":  "yes",
      "encryption":  "NO",
      "inode_limit":  "70656",
      "max_snapshot_id":  1,
      "log_replicas":  0,
      "is_4K_aligned":  "YES",
      "rapid_repair_enabled":  "YES",
      "subblocks_per_full_block":  512,
      "storage_pools":  [
        {
          "name":  "system"
        },
        {
          "name":  "capacity"
      }
      ],
      "file_audit_log":  "NO",
      "maintenance_mode":  "NO_MAINTENANCEMODE",
      "flush_on_close":  "NO",
      "auto_inode_limit":  "NO",
      "disks":  [
        {
          "name":  "nsd1"
        },
        {
          "name":  "nsd2"
        },
        {
          "name":  "nsd3"
        },
        {
          "name":  "nsd6"
        },
        {
          "name":  "nsd7"
        }
      ],
      "automatic_mount_option":  "YES_AUTO",
      "default_mount_point":  "/ibm/fs1",
      "mount_priority":  0,
      "nfs4_owner_write_acl":  "YES",
      "domain_id":  0,
      "manager":  "m1",
      "inode_segment_manager":  "YES",
      "cluster":  "demo",
      "local_version":  "38.00 (6.0.0.0)",
      "original_version":  "38.00 (6.0.0.0)",
      "manager_version":  "38.00 (6.0.0.0)",
      "highest_supported_version":  "38.00 (6.0.0.0)",
      "acldata_maxlen":  "ACLDATAMAXLEN_15"
    }
  ]
}[vagrant@m1 ~]$
```

### Storage Pools

Storage pools allow to integrate different media types such es NVMe, SSD and
NL-SAS into a single filesystem. Each Storage Scale filesystem has at list the
system pool which stores metadata (inodes) and optionally data (content of
files).

```shell
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

```shell
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

Now the filesystem has two storage pools.

```shell
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

List Storage Pools using the REST API:

```shell
curl -k -X 'GET' \
  'https://192.168.56.101:46443/scalemgmt/v3/filesystems/fs1/storagepools' \
  -H 'accept: application/json' \
  -u admin:supersecret
{
  "storage_pools":  [
    {
      "name":  "system",
      "id":  0,
      "filesystem":  "fs1",
      "block_size":  4194304,
      "pool_usage":  "DATA_AND_METADATA",
      "layout_map":  "CLUSTER_BLOCKALLOCATIONTYPE",
      "write_affinity":  "NO",
      "write_affinity_depth":  0,
      "block_group_factor":  1,
      "max_disk_size":  "53678702592",
      "total_data":  "12884901888",
      "free_data":  "12272533504",
      "pct_data_free":  0.9524739583333334,
      "total_metadata":  "12884901888",
      "free_metadata":  "12297699328",
      "pct_metadata_free":  0.9544270833333334
    },
    {
      "name":  "capacity",
      "id":  65537,
      "filesystem":  "fs1",
      "block_size":  4194304,
      "pool_usage":  "DATA_ONLY",
      "layout_map":  "CLUSTER_BLOCKALLOCATIONTYPE",
      "write_affinity":  "NO",
      "write_affinity_depth":  0,
      "block_group_factor":  1,
      "max_disk_size":  "53678702592",
      "total_data":  "12884901888",
      "free_data":  "11077156864",
      "pct_data_free":  0.8597005208333334,
      "free_metadata":  "0"
    }
  ]
}[vagrant@m1 ~]
```

## Disclaimer

**Please note:** This project is released for use "AS IS" without any warranties of any kind, including, but not limited to installation, use, or performance of the resources in this repository.
We are not responsible for any damage, data loss or charges incurred with their use.
This project is outside the scope of the IBM PMR process. If you have any issues, questions or suggestions you can create a new issue [here](https://github.com/IBM/StorageScaleVagrant/issues).
Issues will be addressed as team availability permits.
