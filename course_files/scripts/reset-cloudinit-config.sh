#!/bin/bash
#
# version: 2018060601
#

CLUSTER_NODE_LIST="master01 master02 master03 worker10 worker11 worker12 worker13"
VM_BASE_DIR="/home/VMs"
COURSE_ID="CAAS101"

for NODE in ${CLUSTER_NODE_LIST}
do 
  echo
  echo "-----------------------------------------------------------------------"
  echo "                        ${NODE}"
  echo "-----------------------------------------------------------------------"
  echo
  cp ${VM_BASE_DIR}/${COURSE_ID}/${COURSE_ID}-shared_disks/usb-disk-template.qcow2 ${VM_BASE_DIR}/${COURSE_ID}/${COURSE_ID}-${NODE}/usb-disk.qcow2
done
