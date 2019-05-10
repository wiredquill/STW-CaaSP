#!/bin/bash
for IMAGE in $(cat ./labs)
do
   skopeo copy docker://$IMAGE docker://smt.example.com:5000/$IMAGE
done
