#!/bin/bash

CAASP_INST_ISO_NAME=$(ls /run/media/root | grep SUSE-CaaS-Platform | tail -n 1)
CAASP_INST_ISO_VER=$(echo ${CAASP_INST_ISO_NAME} | cut -d \- -f 4)
CAASP_INST_REPO=/srv/www/htdocs/repo/SUSE/Install/SUSE-CAASP/${CAASP_INST_ISO_VER}/x86_64
CAASP_INST_ISO_DIR=/run/media/root/${CAASP_INST_ISO_NAME}
CAASP_TFTPBOOT_DIR=/srv/tftpboot/caasp

if [ -e ${CAASP_INST_ISO_DIR}/boot/x86_64/loader ]
then
  if [ -e ${CAASP_INST_REPO} ]
  then
    echo
    echo -e "Removing old install files ..."
    echo -e "COMMAND: rm -rf ${CAASP_INST_REPO}/*"
    rm -rf ${CAASP_INST_REPO}/*
  fi

  if [ -e ${CAASP_TFTPBOOT_DIR} ]
  then
    echo
    echo -e "Removing old kernel and initrd ..."
    echo -e "COMMAND: rm -rf ${CAASP_TFTPBOOT_DIR}/*"
    rm -rf ${CAASP_TFTPBOOT_DIR}/*
  fi

  if ! [ -e ${CAASP_INST_REPO} ]
  then
    echo
    echo -e "Creating directory for install files ..."
    echo -e "COMMAND: mkdir -p ${CAASP_INST_REPO}"
    mkdir -p ${CAASP_INST_REPO}
  fi

  echo
  echo -e "Copying new install files ..."
  echo -e "COMMAND: cp -R ${CAASP_INST_ISO_DIR}/* ${CAASP_INST_REPO}/"
  cp -R ${CAASP_INST_ISO_DIR}/* ${CAASP_INST_REPO}/

  if ! [ -e ${CAASP_TFTPBOOT_DIR} ]
  then
    echo
    echo -e "Creating directory for tftp boot files ..."
    echo -e "COMMAND: mkdir -p ${CAASP_TFTPBOOT_DIR}"
    mkdir -p ${CAASP_TFTPBOOT_DIR}
  fi

  echo
  echo -e "Copying install kernel and initrd ..."
  echo -e "COMMAND: cp ${CAASP_INST_REPO}/boot/x86_64/loader/initrd ${CAASP_TFTPBOOT_DIR}/"
  cp ${CAASP_INST_REPO}/boot/x86_64/loader/initrd ${CAASP_TFTPBOOT_DIR}/
  echo -e "COMMAND: cp ${CAASP_INST_REPO}/boot/x86_64/loader/linux ${CAASP_TFTPBOOT_DIR}/"
  cp ${CAASP_INST_REPO}/boot/x86_64/loader/linux ${CAASP_TFTPBOOT_DIR}/


  echo
  echo -e "---Finished---"
else
  echo
  echo -e "ERROR: The CaaSP installation ISO does not seem to be mounted."
  echo
  echo -e "Exiting ..."
fi
