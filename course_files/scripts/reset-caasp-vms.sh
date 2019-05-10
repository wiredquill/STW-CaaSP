#!/bin/bash
#version: 2018020601

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
IMAGE_SRC_DIR=/home/images/${COURSE_ID}
VM_BASE_DIR=/home/VMs/${COURSE_ID}
CLOUDINIT_TEMPLATE_DISK=${VM_BASE_DIR}/${COURSE_ID}-shared_disks/usb-disk-template.qcow2
if [ -e /proc/net/vlan/vlan-caasp ]
then
  APPEND="-multi_lm"
else
  APPEND=""
fi

INSTALL_VM_LIST="admin master01 master02 master03 worker10 worker11 worker12 "
IMAGE_VM_LIST="worker13"
IMAGE_FILE="SUSE-CaaS-Platform-3.0-for-KVM-and-Xen.x86_64-3.0.0-Build14.3.qcow2"

###############################################################################
#  Functions
###############################################################################

reset_install_vms() {
  cd ${VM_BASE_DIR}

  for VM in ${INSTALL_VM_LIST}
  do
    echo -e "${LTBLUE}*************************  VM: ${ORANGE}${VM}  ${LTBLUE}****************************${NC}"
    echo
    echo -e "${GREEN}COMMAND: ${GRAY}virsh destroy ${COURSE_ID}-${VM}${NC}"
    virsh destroy ${COURSE_ID}-${VM}
    echo -e "${GREEN}COMMAND: ${GRAY}virsh undefine ${COURSE_ID}-${VM}${NC}"
    virsh undefine ${COURSE_ID}-${VM}
    echo -e "${GREEN}COMMAND: ${GRAY}virsh define ${VM_BASE_DIR}/${COURSE_ID}-${VM}/${COURSE_ID}-${VM}${APPEND}.xml${NC}"
    virsh define ${VM_BASE_DIR}/${COURSE_ID}-${VM}/${COURSE_ID}-${VM}${APPEND}.xml

    sudo chmod 777 ${VM_BASE_DIR}/${COURSE_ID}-${VM}/${COURSE_ID}-${VM}.qcow2
    /usr/local/bin/reset-vm-disk-image.sh ${COURSE_ID}-${VM}

    #virsh destroy CAAS101-${VM}
    #/usr/local/bin/reset-vm-disk-image.sh CAAS101-${VM}

    case ${VM} in
      admin)
        if [ -e ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2 ]
        then
          echo "(skipping admin usb-disk.qcow2)"
          echo
        fi
      ;;
      *)
        if [ -e ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2 ]
        then
          echo -e "${GREEN}COMMAND: ${GRAY}sudo rm -f ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2${NC}"
          sudo rm -f ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2
          echo -e "${GREEN}COMMAND: ${GRAY}cp ${CLOUDINIT_TEMPLATE_DISK} ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2${NC}"
          cp ${CLOUDINIT_TEMPLATE_DISK} ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2
        fi
        echo
      ;;
    esac
  done
}

reset_image_vms() {
  cd ${VM_BASE_DIR}

  for VM in ${IMAGE_VM_LIST}
  do
    echo -e "${LTBLUE}*************************  VM: ${ORANGE}${VM}  ${LTBLUE}****************************${NC}"
    echo
    echo -e "${GREEN}COMMAND: ${GRAY}virsh destroy ${COURSE_ID}-${VM}${NC}"
    virsh destroy ${COURSE_ID}-${VM}
    echo -e "${GREEN}COMMAND: ${GRAY}virsh undefine ${VM}${NC}"
    virsh undefine ${VM}
    echo -e "${GREEN}COMMAND: ${GRAY}virsh define ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}${APPEND}.xml${NC}"
    virsh define ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}${APPEND}.xml
    echo
    echo -e "${LTBLUE}======================================================================${NC}"
    echo -e "${LTBLUE}Reseting the virtual disk: ${ORANGE}./${COURSE_ID}/${COURSE_ID}-${VM}.qcow2${NC}"
    echo -e "${LTBLUE}======================================================================${NC}"
    echo

    echo -e "${GREEN}COMMAND: ${GRAY}cd ./${COURSE_ID}-${VM}${NC}"
    echo -e "${GREEN}COMMAND: ${GRAY}sudo cp ${IMAGE_SRC_DIR}/${IMAGE_FILE} ${VM_BASE_DIR}/${COURSE_ID}-${VM}/${COURSE_ID}-${VM}.qcow2${NC}"
    sudo cp ${IMAGE_SRC_DIR}/${IMAGE_FILE} ${VM_BASE_DIR}/${COURSE_ID}-${VM}/${COURSE_ID}-${VM}.qcow2
    echo

    if [ -e ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2 ]
    then
      echo -e "${GREEN}COMMAND: ${GRAY}sudo rm -f ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2${NC}"
      sudo rm -f ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2
      echo -e "${GREEN}COMMAND: ${GRAY}cp ${CLOUDINIT_TEMPLATE_DISK} ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2${NC}"
      cp ${CLOUDINIT_TEMPLATE_DISK} ${VM_BASE_DIR}/${COURSE_ID}-${VM}/usb-disk.qcow2
    fi
    echo
    echo -e "${LTBLUE}=============================  Finished  =============================${NC}"
    echo
  done
}

main() {

  echo
  echo -e "${LTBLUE}###############################################################################${NC}"
  echo -e "${LTBLUE}#                   Reseting ${COURSE_ID} VMs${NC}"
  echo -e "${LTBLUE}###############################################################################${NC}"
  echo

  if ! [ -z "${INSTALL_VM_LIST}" ]
  then
    reset_install_vms
  fi

  if ! [ -z "${IMAGE_VM_LIST}" ]
  then
    reset_image_vms
  fi
}

###############################################################################
#  Main Code Body
###############################################################################

main
