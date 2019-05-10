#!/bin/bash

if [ -z ${1} ]
then
  echo
  echo "ERROR: You must provide the path to the cloud-init qcow2 disk image file."
  echo
  echo "USAGE: ${0} <path_to_cloud-init_qcow2_file>"
  echo
  exit 1
else
  IMAGE_FILE=${1}
  if [ -e ${1} ]
  then
    echo "-Mounting qcow2 file ..."
    sudo guestmount -a ${IMAGE_FILE} -m /dev/sda /mnt
    echo "-Opening files for editing ..."
    sleep 2
    sudo vi /mnt/meta-data
    sudo vi /mnt/user-data
    echo "-Unmounting qcow2 file ..."
    sudo umount /mnt
    echo "-Finished"
  else
    echo
    echo "ERROR: The cloud-init qcow2 disk image file specifed doesn't exist."
    echo
    exit 1
  fi
fi
