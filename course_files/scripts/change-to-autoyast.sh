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
VM_BASE_DIR=/home/VMs
if [ -e /proc/net/vlan/vlan-caasp ]
then
  APPEND="-multi_lm"
else
  APPEND=""
fi

###############################################################################
#  Functions
###############################################################################

usage() {
  echo
  echo -e "${GRAY}USAGE: ${0} <vm_name>${NC}"
  echo
}

change_to_autoyast() {
  echo
  echo -e "${LTBLUE}-Powering off VM (${ORANGE}${VM}${LTBLUE}) ...${NC}"
  echo -e "${GREEN}COMMAND: ${GRAY}virsh destroy ${VM}${NC}"
  virsh destroy ${VM}
  echo -e "${GREEN}COMMAND: ${GRAY}virsh undefine ${VM}${NC}"
  virsh undefine ${VM}
  echo -e "${GREEN}COMMAND: ${GRAY}virsh define ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}${APPEND}.xml${NC}"
  virsh define ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}${APPEND}.xml
  echo

  cd ${VM_BASE_DIR}/${COURSE_ID}
  sudo chmod 777 ${VM_BASE_DIR}/${COURSE_ID}/${VM}/${VM}.qcow2
  /usr/local/bin/reset-vm-disk-image.sh ${VM}
}
###############################################################################
#  Main Code Body
###############################################################################

if [ -z ${1} ]
then
  echo
  echo -e "${LTRED}ERROR: You must provide the name of the VM to change to \"installing from autoyast\".${NC}"
  usage
  exit 1
else
  VM=${1}
  #if virsh list --all | grep -q ${VM}
  if [ -e ${VM_BASE_DIR}/${COURSE_ID}/${VM} ]
  then
    change_to_autoyast
  else
    echo
    echo -e "${LTRED}ERROR: The VM specified (${ORANGE}${VM}${LTRED}) doesn't seem to exist.${NC}"
    echo
    exit 1
  fi
fi
