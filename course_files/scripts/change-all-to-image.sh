#!/bin/bash
#version: 2018060601

###############################################################################
#  Global Vars
###############################################################################

### Colors ###
RED='\e[0;31m'
LTRED='\e[1;31m'
BLUE='\e[0;34m'
LTBLUE='\e[1;34m'
GREEN='\e[0;32m'
LTGREEN='\e[1;32m'
ORANGE='\e[0;33m'
YELLOW='\e[1;33m'
CYAN='\e[0;36m'
LTCYAN='\e[1;36m'
PURPLE='\e[0;35m'
LTPURPLE='\e[1;35m'
GRAY='\e[1;30m'
LTGRAY='\e[0;37m'
WHITE='\e[1;37m'
NC='\e[0m'
##############

COURSE_ID=CAAS101
VM_BASE_DIR=/home/VMs
IMAGE_SRC_DIR=/home/images
IMAGE_FILE="SUSE-CaaS-Platform-3.0-for-KVM-and-Xen.x86_64-3.0.0-GM.qcow2"
if [ -e /proc/net/vlan/vlan-caasp ]
then
  APPEND="-with_usb-multi_lm"
else
  APPEND="-with_usb"
fi

VM_LIST="${COURSE_ID}-admin ${COURSE_ID}-master01 ${COURSE_ID}-master02 ${COURSE_ID}-master03 ${COURSE_ID}-worker10 ${COURSE_ID}-worker11 ${COURSE_ID}-worker12 ${COURSE_ID}-worker13 "

###############################################################################
#  Functions
###############################################################################

usage() {
  echo
  echo -e "${GRAY}USAGE: ${0} <vm_name>${NC}"
  echo
}

change_to_image() {
  echo
  echo -e "${LTBLUE}-Powering off VM (${ORANGE}${VM}${LTBLUE}) ...${NC}"
  echo -e "${GREEN}COMMAND: ${GRAY}virsh destroy ${VM}${NC}"
  virsh destroy ${VM}
  echo -e "${GREEN}COMMAND: ${GRAY}virsh undefine ${VM}${NC}"
  virsh undefine ${VM}
  echo -e "${GREEN}COMMAND: ${GRAY}virsh define ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}${APPEND}.xml${NC}"
  virsh define ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}${APPEND}.xml
  echo

  sudo chmod 777 ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}.qcow2
  echo -e "${LTBLUE}-Copying qcow2 image file ...${NC}"
  echo -e "${GREEN}COMMAND: ${GRAY}sudo cp ${IMAGE_SRC_DIR}/${COURSE_ID}/${IMAGE_FILE} ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}.qcow2${NC}"
  sudo cp ${IMAGE_SRC_DIR}/${COURSE_ID}/${IMAGE_FILE} ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}.qcow2
  sudo chown .users ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}.qcow2
  sudo chmod g+rw ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}.qcow2
  echo
}

reset_cloudinit_config() {
  sudo chmod 777 ${VM_BASE_DIR}/${COURSE_ID}/${VM}/usb-disk.qcow2
  echo -e "${LTBLUE}-Resetting cloud-init config ...${NC}"
  echo -e "${GREEN}COMMAND: ${GRAY}cp ${VM_BASE_DIR}/${COURSE_ID}/${COURSE_ID}-shared_disks/usb-disk-template.qcow2 ${VM_BASE_DIR}/${COURSE_ID}/${VM}/usb-disk.qcow2${NC}"
  sudo cp ${VM_BASE_DIR}/${COURSE_ID}/${COURSE_ID}-shared_disks/usb-disk-template.qcow2 ${VM_BASE_DIR}/${COURSE_ID}/${VM}/usb-disk.qcow2
  sudo chown .users ${VM_BASE_DIR}/${COURSE_ID}/${VM}/usb-disk.qcow2
  sudo chmod g+rw ${VM_BASE_DIR}/${COURSE_ID}/${VM}/usb-disk.qcow2
  echo
}

###############################################################################
#  Main Code Body
###############################################################################

for VM in ${VM_LIST}
do
  echo
  echo -e "${LTBLUE}--------------------------------------------------------${NC}"
  #if virsh list --all | grep -q ${VM}
  if [ -e ${VM_BASE_DIR}/${COURSE_ID}/${VM} ]
  then
    change_to_image
    if ! echo ${VM} | grep -q admin
    then
      reset_cloudinit_config
    else
      echo -e "${LTBLUE}-Skipping resetting cloud-init config for the admin node (not needed) ...${NC}"
    fi
  else
    echo
    echo -e "${LTRED}ERROR: The VM specified (${ORANGE}${VM}${LTRED}) doesn't seem to exist. Skipping ...${NC}"
    echo
  fi
done
