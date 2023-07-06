#!/usr/bin/bash


# Improve readability of output
echo "========================================================================================="
echo "===>"
echo "===> Running $0"
echo "===> Create filesets and some example data"
echo "===>"
echo "========================================================================================="

# Print commands and their arguments as they are executed
set -x

# Exit script immediately, if one of the commands returns error code
set -e


# Create example groups
echo "===> Create example groups"
sudo groupadd flowers
sudo groupadd pets

# Create example users
echo "===> Creating example users"
sudo useradd admin_flowers -g flowers
sudo useradd daffodils     -g flowers
sudo useradd roses         -g flowers
sudo useradd tulips        -g flowers
sudo useradd admin_pets    -g pets
sudo useradd cats          -g pets
sudo useradd dogs          -g pets
sudo useradd hamsters      -g pets

# Create Storage Scale Filesets
echo "===> Create Storage Scale Filesets"
sudo mmcrfileset fs1 pets    -t "Cute Pets"
sudo mmcrfileset fs1 flowers -t "Lovely Flowers"

# Link Storage Scale Filesets
echo "===> Link Storage Scale Filesets"
sudo mmlinkfileset fs1 pets    -J /ibm/fs1/pets
sudo mmlinkfileset fs1 flowers -J /ibm/fs1/flowers

# Create directories for users
echo "===> Create directories for users"
sudo mkdir /ibm/fs1/flowers/daffodils
sudo mkdir /ibm/fs1/flowers/roses
sudo mkdir /ibm/fs1/flowers/tulips
sudo mkdir /ibm/fs1/pets/cats
sudo mkdir /ibm/fs1/pets/dogs
sudo mkdir /ibm/fs1/pets/hamsters

# Create some files in each user directory
# Note: The algorithm creates files of varying sizes so that quota reports
#       have varying sizes
echo "===> Create some files in each user directory"
inc=3
for dir in /ibm/fs1/*/* ; do
  inc=$(($inc+1))
  num_files=$((10+$inc))
  cur_file=$((0))
  while [ $cur_file -lt $num_files ] ; do
    cur_file=$(($cur_file+1))
    num_blocks=$((10+17*$cur_file))
    sudo dd if=/dev/zero of=$dir/file$cur_file bs=100K count=$num_blocks 2>/dev/null
  done
done

# Set owner of Storage Scale Filesets
echo "===> Set owner of Storage Scale Filesets"
sudo chown admin_flowers:flowers /ibm/fs1/flowers
sudo chown admin_pets:pets       /ibm/fs1/pets

# Set ownership of files
echo "===> Set ownership of files"
sudo chown -R cats:pets         /ibm/fs1/pets/cats
sudo chown -R dogs:pets         /ibm/fs1/pets/dogs
sudo chown -R hamsters:pets     /ibm/fs1/pets/hamsters
sudo chown -R tulips:flowers    /ibm/fs1/flowers/tulips
sudo chown -R roses:flowers     /ibm/fs1/flowers/roses
sudo chown -R daffodils:flowers /ibm/fs1/flowers/daffodils


# Exit successfully
echo "===> Script completed successfully!"
exit 0
