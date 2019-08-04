#!/bin/bash
USERNAME=root
HOSTS="master01 worker10 worker10"
for HOSTNAME in ${HOSTS} ; do
    scp course_files/certs/domain.crt root@${HOSTNAME}://etc/pki/trust/anchors/ 
done


for HOSTNAME in ${HOSTS} ; do
    ssh -l ${USERNAME} ${HOSTNAME} update-ca-certificates
done