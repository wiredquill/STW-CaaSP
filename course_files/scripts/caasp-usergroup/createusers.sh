#!/bin/bash

# Get LDAP_PASSWORD
LDAP_PASSWORD=$(cat pass.txt)

# Set ENV
export LDAPTLS_REQCERT=never

# test
echo $LDAP_PASSWORD

# Create Users

for user in alpha beta gamma delta; do
    	ldapadd -H ldap://192.168.110.99:389 -ZZ -D cn=admin,dc=infra,dc=caasp,dc=local -w "$LDAP_PASSWORD" -f ldifs/$user.ldif
done

# Create groups

bash caasp-groupadd.sh -g greeks -a 192.168.110.99 -A admin -w $LDAP_PASSWORD
bash caasp-groupadd.sh -g coolpeople -a 192.168.110.99 -A admin -w $LDAP_PASSWORD

# Add users to groups

for group in alpha beta gamma delta; do
	bash caasp-group_add_user.sh -u $group -g greeks -a 192.168.110.99 -A admin -w $LDAP_PASSWORD
done
