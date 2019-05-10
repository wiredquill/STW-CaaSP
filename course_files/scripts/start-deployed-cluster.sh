#!/bin/bash

VM_LIST="
CAAS101-smt:30
CAAS101-admin:120
CAAS101-master01:20
CAAS101-master02:10
CAAS101-master03:30
CAAS101-worker10:10
CAAS101-worker11:10
CAAS101-worker12:10
"

start_vms() {
  for VM in ${VM_LIST}
  do
    local VM_NAME=$(echo ${VM} | cut -d : -f 1)
    local SLEEP_TIME=$(echo ${VM} | cut -d : -f 2)
    echo "Starting VM: ${VM_NAME}"
    echo "--------------------------------------------------"
    echo "COMMAND:  virsh start ${VM_NAME}"
    virsh start ${VM_NAME}
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

start_vms

