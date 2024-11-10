#!/bin/bash

# To store roles with desired permissions
declare -a TARGET_ROLES=()
declare -a PERMISSIONS_TABLE=()

# Enumerate and store org_id
#ORG_ID=$(gcloud organizations list --format="value(name)")
#echo " Org ID is $ORG_ID"

# Enumerate built-in roles in org
ALL_ROLES=$(gcloud iam roles list --filter="name:roles/*" --format="value(name)")
echo "Collecting all roles..."
#ALL_ROLES+=$(gcloud iam roles list --organization=$ORG_ID --format="value(name)" | cut -d'/' -f4)
#echo " Roles are $ALL_ROLES"

echo "loading permissions from file"
while read line; do
	PERMISSIONS_TABLE+=("$line")
done < permissions_list.txt

for role in $ALL_ROLES; do
    # Get permissions for each role and search for the specified permissions
    PERMISSIONS=$(gcloud iam roles describe $role --format="value(includedPermissions)")
	
	for permission in ${PERMISSIONS_TABLE[@]}; do
		if [[ $PERMISSIONS == *$permission* ]]; then
			echo "Role $role has permission $permission"
			TARGET_ROLES+=("$role")
		fi
	done
done

echo "Saving data to file..."
printf "%q " "${TARGET_ROLES[*]}" > temp_file_with_default_roles_containing_high_priveleges.txt
