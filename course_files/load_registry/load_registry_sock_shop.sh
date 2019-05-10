#!/bin/bash
for IMAGE in $(cat ./sock_shop)
do
   skopeo copy docker://$IMAGE docker://smt.example.com:5000/$IMAGE
done
