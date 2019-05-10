#!/bin/bash

REGISTRY="smt.example.com"
CONTAINER_LIST="
gcr.io/google_containers/kubernetes-dashboard-init-amd64:v1.0.1
gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1
gcr.io/google_containers/kubernetes-dashboard-amd64:v1.6.3
gcr.io/google_containers/heapster-grafana-amd64:v4.0.2
gcr.io/google_containers/heapster-amd64:v1.3.0
gcr.io/google_containers/heapster-influxdb-amd64:v1.3.3
mysql:5.6
nginx:1.7.9
nginx:1.12.0
busybox
gcr.io/google_containers/hpa-example
quay.io/external_storage/nfs-client-provisioner:latest
gcr.io/google_containers/busybox:1.24
bitnami/dokuwiki:latest
nginx:1.9.0
gcr.io/google_containers/busybox:1.24

"

echo
echo "Mirroring container images ..."
echo "-------------------------------------------------------"
for IMAGE in ${CONTAINER_LIST}
do
  echo "-${IMAGE}"
  skopeo copy docker://${IMAGE} docker://${REGISTRY}:5000/${IMAGE}
done
