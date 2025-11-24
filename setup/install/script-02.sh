#!/usr/bin/bash

TASK="Extract Storage Scale RPMs"

source /vagrant/install/common-preamble.sh

# Pin the version and the edition of Storage Scale, until project runs stable for a while
install=/software/Storage_Scale_Developer-$VERSION-x86_64-Linux-install
# Abort with error code, if Storage Scale directroy exists
echo "===> Check for Storage Scale directrory"
if [ -d "/usr/lpp/mmfs" ]; then
    echo "===> Directory exists: /usr/lpp/mmfs"
    exit 1
fi

# Make self-extracting install package executable
chmod 555 $install

# Extract Storage Scale RPMs
echo "===> Extract Storage Scale PRMs"
sudo $install --silent

# Patch for Rocky Linux support
echo "===> Patch for Rocky Linux support"
cd /usr/lpp/mmfs/${VERSION}/ansible-toolkit/ansible/ibm-spectrum-scale-install-infra/roles/core_common/vars
dnf -y install patch
cat <<EOF>/tmp/rocky1.patch
--- main.yml.orig	2025-07-07 16:53:34.590395287 +0000
+++ main.yml	2025-07-07 16:53:48.707667130 +0000
@@ -31,6 +31,7 @@
 scale_rhel_distribution:
   - RedHat
   - CentOS
+  - Rocky
 
 ## Supported scale os distrubution
 scale_sles_distribution:
EOF
patch -p0 < /tmp/rocky1.patch
cd /usr/lpp/mmfs/${VERSION}/ansible-toolkit/ansible/ibm-spectrum-scale-install-infra/roles/core_install/vars
cat <<EOF>/tmp/rocky2.patch
--- main.yml.orig	2025-07-07 17:00:47.610918841 +0000
+++ main.yml	2025-07-07 17:00:58.104105969 +0000
@@ -31,6 +31,7 @@
 scale_rhel_distribution:
   - RedHat
   - CentOS
+  - Rocky
 
 ## Supported scale os distrubution
 scale_sles_distribution:
EOF
patch -p0 < /tmp/rocky2.patch

# Exit successfully
echo "===> Script completed successfully!"
exit 0
