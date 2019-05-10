#!/bin/bash

###############################################################################
#   Global Vars
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

VM_BASE_DIR="/home/VMs"
COURSE_ID="CAAS101"
ADMIN_NODE_IP="192.168.110.99"
SSH_TMP_FILE="/tmp/admin-sshpubkey.pub"
TMP_MOUNTPOINT="/mnt"

CLUSTER_NODES="master01 master02 master03 worker10 worker11 worker12 worker13"


###############################################################################
#   Functions
###############################################################################

update_cloudinit_userdata() {
  for VM in ${CLUSTER_NODES}
  do
    echo
    echo -e "${LTBLUE}--------------------------------------------------------------${NC}"
    echo -e "${LTBLUE}                     VM: ${ORANGE}${VM} ${NC}"
    echo -e "${LTBLUE}--------------------------------------------------------------${NC}"
    echo
    echo -e "${GREEN}COMMAND: ${GRAY}sudo guestmount -a ${VM_BASE_DIR}/${COURSE_ID}/${COURSE_ID}-${VM}/usb-disk.qcow2 -m /dev/sda ${TMP_MOUNTPOINT}${NC}"
    sudo guestmount -a ${VM_BASE_DIR}/${COURSE_ID}/${COURSE_ID}-${VM}/usb-disk.qcow2 -m /dev/sda ${TMP_MOUNTPOINT}
    echo

    if mount | grep -q " ${TMP_MOUNTPOINT} " 
    then
      echo -e "${GREEN}COMMAND: ${GRAY}sudo sed -i \"s%_ADMIN_SSH_KEY_GOES_HERE_%${ADMIN_SSHPUBKEY}%g\" ${TMP_MOUNTPOINT}/user-data${NC}"
      sudo sed -i "s%_ADMIN_SSH_KEY_GOES_HERE_%${ADMIN_SSHPUBKEY}%g" ${TMP_MOUNTPOINT}/user-data
      echo -e "${GREEN}COMMAND: ${GRAY}sudo sed -i \"s%_NODE_NAME_GOES_HERE_%${VM}%g\" ${TMP_MOUNTPOINT}/user-data${NC}"
      sudo sed -i "s%_NODE_NAME_GOES_HERE_%${VM}%g" ${TMP_MOUNTPOINT}/user-data
      echo -e "${GREEN}COMMAND: ${GRAY}sudo sed -i \"s%_ADMIN_NODE_IP_GOES_HERE_%${ADMIN_NODE_IP}%g\" ${TMP_MOUNTPOINT}/user-data${NC}"
      sudo sed -i "s%_ADMIN_NODE_IP_GOES_HERE_%${ADMIN_NODE_IP}%g" ${TMP_MOUNTPOINT}/user-data

      echo
      echo -e "${GREEN}COMMAND: ${GRAY}sudo sed -i \"s%_NODE_NAME_GOES_HERE_%${VM}%g\" ${TMP_MOUNTPOINT}/meta-data${NC}"
      sudo sed -i "s%_NODE_NAME_GOES_HERE_%${VM}%g" ${TMP_MOUNTPOINT}/meta-data
    fi

    echo
    echo -e "${GREEN}COMMAND: ${GRAY}sudo umount ${TMP_MOUNTPOINT}${NC}"
    sudo umount ${TMP_MOUNTPOINT}
    echo
done
}


###############################################################################
#   Main Code Body
###############################################################################

echo
echo -e "${LTBLUE}##############################################################${NC}"
echo -e "${LTBLUE}        Updating the cloud-init user-data files ...${NC}"
echo -e "${LTBLUE}##############################################################${NC}"
echo

if virsh list | grep -q "${COURSE_ID}-admin"
then
  echo -e "${LTCYAN}==============================================================${NC}"
  echo -e "${LTCYAN}  Retrieving the admin SSH public key ...${NC}"
  echo -e "${LTCYAN}==============================================================${NC}"
  echo

  echo -e "${GREEN}COMMAND: ${GRAY}rm -f ${SSH_TMP_FILE}${NC}"
  rm -f ${SSH_TMP_FILE}

  echo -e "${GREEN}COMMAND: ${GRAY}scp root@${ADMIN_NODE_IP}:/root/.ssh/id_rsa.pub ${SSH_TMP_FILE}${NC}"
  scp root@${ADMIN_NODE_IP}:/root/.ssh/id_rsa.pub ${SSH_TMP_FILE}
else
  echo
  echo -e "${RED}ERROR: The ${COUSE_ID}-admin VM does not appear to be running.${NC}"
  echo
  exit 1
fi

if [ -e ${SSH_TMP_FILE} ]
then
  ADMIN_SSHPUBKEY="$(cat ${SSH_TMP_FILE})"
  #echo "ADMIN_SSHPUBKEY=${ADMIN_SSHPUBKEY}";read

  echo -e "${GREEN}COMMAND: ${GRAY}rm -f ${SSH_TMP_FILE}${NC}"
  rm -f ${SSH_TMP_FILE}

  echo
  echo -e "${LTCYAN}==============================================================${NC}"
  echo -e "${LTCYAN}  Updating the files in the VMs ...${NC}"
  echo -e "${LTCYAN}==============================================================${NC}"

  update_cloudinit_userdata
else
  echo 
  echo "${RED}ERROR: The ssh public key file (${SSH_TMP_FILE}) doesn't appear to exist.${NC}"
  echo
  exit 1
fi
