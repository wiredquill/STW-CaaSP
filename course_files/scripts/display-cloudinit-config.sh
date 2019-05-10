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
  sudo guestmount -a ${VM_BASE_DIR}/${COURSE_ID}/${COURSE_ID}-${NODE}/usb-disk.qcow2 -m /dev/sda --ro /mnt
  echo "----- [meta-data] -----"
  echo
  sudo cat /mnt/meta-data
  #echo "--------------------------------------------------"
  echo
  echo "----- [user-data] -----"
  echo
  sudo cat /mnt/user-data
  sudo umount /mnt
done

echo
