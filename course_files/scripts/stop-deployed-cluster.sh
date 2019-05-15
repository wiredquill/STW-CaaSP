#!/bin/bash

VM_LIST="
CAAS101-worker11:5
CAAS101-worker10:30
CAAS101-master01:30
CAAS101-admin:10
CAAS101-smt:1
"

stop_vms() {
  for VM in ${VM_LIST}
  do
    local VM_NAME=$(echo ${VM} | cut -d : -f 1)
    local SLEEP_TIME=$(echo ${VM} | cut -d : -f 2)
    echo "Stopping VM: ${VM_NAME}"
    echo "--------------------------------------------------"
    echo "COMMAND:  virsh shutdown ${VM_NAME}"
    virsh shutdown ${VM_NAME}
    local COUNT=0
    while [ "${COUNT}" -le "${SLEEP_TIME}" ]
    do
      echo -n "."
      sleep 1
      ((COUNT++))
    done
    echo "."
    echo
  done
}

##################################################

stop_vms

