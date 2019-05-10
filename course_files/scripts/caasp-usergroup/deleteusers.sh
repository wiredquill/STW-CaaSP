#!/bin/bash

# Get LDAP_PASSWORD
LDAP_PASSWORD=$(cat pass.txt)

# Set ENV
export LDAPTLS_REQCERT=never

# test
echo $LDAP_PASSWORD

# Delete users
for user in alpha beta gamma delta; do
        bash ./caasp-userdel.sh -u $user -a 192.168.110.99 -A admin -w $LDAP_PASSWORD
done
