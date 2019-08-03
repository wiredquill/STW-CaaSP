#!/bin/bash
USERNAME=root
HOSTS="master01 worker10 worker10"
for HOSTNAME in ${HOSTS} ; do
    scp domain.crt root@${HOSTNAME}:/tmp 
done

SCRIPT="pwd; ls"
for HOSTNAME in ${HOSTS} ; do
    ssh -l ${USERNAME} ${HOSTNAME} "${SCRIPT}"
done