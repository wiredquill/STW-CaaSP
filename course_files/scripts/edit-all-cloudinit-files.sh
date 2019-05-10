#!/bin/bash

NODE_LIST="admin master01 master02 master03 worker10 worker11 worker12 worker13"
VM_BASE_DIR="/home/VMs"
COURSE_ID="CAAS101"

for NODE in ${NODE_LIST}
do
  echo
  echo "-----------------------------------------------------------------------"
  echo "                        ${NODE}"
  echo "-----------------------------------------------------------------------"
  echo
  echo "-Mounting qcow2 disk ..."
  sudo guestmount -a ${VM_BASE_DIR}/${COURSE_ID}/${COURSE_ID}-${NODE}/usb-disk.qcow2 -m /dev/sda /mnt
  echo
  echo "-Opening files for editing ..."
  sleep 2
  sudo vi /mnt/meta-data
  sudo vi /mnt/user-data
  echo
  echo "-Unmounting qcow2 disk ..."
  sudo umount /mnt
done

echo
