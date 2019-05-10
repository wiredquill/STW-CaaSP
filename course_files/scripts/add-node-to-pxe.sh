#!/bin/bash

CAASP_ADMIN_IP="192.168.110.99"
SMT_IP="192.168.110.2"
DNS_ZONE_FILE_DIR="/var/lib/named/master"
DNS_ZONE_FILE="${DNS_ZONE_FILE_DIR}/example.com"
CAASP_INST_VER=$(ls /srv/www/htdocs/repo/SUSE/Install/SUSE-CAASP/ | tail -n 1)
CAASP_INST_REPO_DIR="/repo/SUSE/Install/SUSE-CAASP/${CAASP_INST_VER}/x86_64"
PXE_CFG_DIR="/srv/tftpboot/pxelinux.cfg"

usage() {
  echo
  echo "USAGE: ${0} <node_MAC_addr> <node_IP_addr> <node_name> [<caasp_admin_ip>]"
  echo
}

update_dhcp_add_node() {
  echo "Adding node to DHCP ..."
  sed -i '/^}/d' /etc/dhcpd.conf

  echo "  host ${NODE_NAME} {fixed-address ${NODE_IP}; hardware ethernet ${NODE_MAC};}" >> /etc/dhcpd.conf
  echo "}" >> /etc/dhcpd.conf

  systemctl restart dhcpd
}

update_dns_add_node() {
  echo "Adding node to DNS ..."
  echo "${NODE_NAME}          IN A            ${NODE_IP}" >> ${DNS_ZONE_FILE}
}

create_pxe_config() {
echo "Creating PXD boot config file ..."
echo "default vesamenu.c32
timeout 100

menu title PXE Install Server

label harddisk
  menu label Local Hard Disk
  localboot 0

label install-${NODE_MAC}
  menu label install-${NODE_MAC} (${NODE_NAME})
  kernel caasp/linux
  append load_ramdisk=1 initrd=caasp/initrd netsetup=dhcp hostname=${NODE_NAME} autoyast=http://${CAASP_ADMIN_IP}/autoyast install=http://${SMT_IP}${CAASP_INST_REPO_DIR}
" > ${PXE_CFG_DIR}/01-$(echo ${NODE_MAC} | tr : -)
}

create_pxe_config_admin() {
echo "default vesamenu.c32
timeout 100

menu title PXE Install Server

label harddisk
  menu label Local Hard Disk
  localboot 0

label install-${NODE_MAC}
  menu label install-${NODE_MAC} (${NODE_NAME})
  kernel caasp/linux
  append load_ramdisk=1 initrd=caasp/initrd netsetup=dhcp hostname=${NODE_NAME} install=http://${SMT_IP}${CAASP_INST_REPO_DIR}
" > ${PXE_CFG_DIR}/01-$(echo ${NODE_MAC} | tr : -)
}

##########################################################################

if [ -z ${1} ]
then
  echo
  echo "ERROR: You must specify the node's MAC address."
  echo
  usage
  exit 1
else
  NODE_MAC=${1}
fi

if [ -z ${2} ]
then
  echo
  echo "ERROR: You must specify the node's IP address."
  echo
  usage
  exit 2
else
  NODE_IP=${2}
fi
if [ -z ${3} ]
then
  echo
  echo "ERROR: You must specify the node's name."
  echo
  usage
  exit 3
else
  NODE_NAME=${3}
fi
if ! [ -z ${4} ]
then
  CAASP_ADMIN_IP=${4}
fi

#echo
#echo "NODE_MAC=${NODE_MAC}"
#echo "NODE_IP=${NODE_IP}"
#echo "NODE_NAME=${NODE_NAME}"
#echo "CASP_ADMIN_IP=${CAASP_ADMIN_IP}"
#echo "Node PXE Config File: ${PXE_CFG_DIR}/01-$(echo ${NODE_MAC} | tr : -)"

update_dhcp_add_node
update_dns_add_node
case ${3} in
  admin)
    create_pxe_config_admin
  ;;
  *)
    create_pxe_config
  ;;
esac
