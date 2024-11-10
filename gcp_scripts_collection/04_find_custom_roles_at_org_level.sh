#!/bin/bash

declare -a CONFIRMED_ROLES=()
declare -a my_table=()
declare -a PERMISSIONS_TABLE=()

echo "all custom roles from org level"

# Enumerate and store org_id
#ORG_ID=$(gcloud organizations list --format="value(name)")
ORG_ID=$1


# Enumerate custom roles in org
#ALL_ROLES_ORG+=$(gcloud iam roles list --organization=$ORG_ID --format="value(name)" | cut -d'/' -f4)
ALL_ROLES_ORG+=$(gcloud iam roles list --organization=$ORG_ID --format="value(name)")
#echo " Roles at org level are $ALL_ROLES_ORG"


echo "loading permissions from file"
while read line; do
        PERMISSIONS_TABLE+=("$line")
done < permissions_list.txt

for role in $ALL_ROLES_ORG; do
	

    SHORT_ROLE_NAME=$(echo $role | cut -d'/' -f4)	
    # Get permissions for each role and search for the specified permissions
    PERMISSIONS=$(gcloud iam roles describe $SHORT_ROLE_NAME --format="value(includedPermissions)"  --organization=$ORG_ID)


	  for permission in ${PERMISSIONS_TABLE[@]}; do
                if [[ $PERMISSIONS == *$permission* ]]; then
                        echo "Role $role has permission $permission"
                        TARGET_ROLES+=("$role")
                fi
        done

done


#echo " Roles at org level with highly sensiitive permissions $TARGET_ROLES"

#enumerate policy at org level
#========================

POLICY=$(gcloud organizations get-iam-policy $ORG_ID --format=json)

 for target_role in "${TARGET_ROLES[@]}";do
	
	MEMBERS=$(echo $POLICY | jq -r --arg role "$target_role" '.bindings[] | select(.role == $role) | .members[]')
	  if [ ! -z "$MEMBERS" ]; then
                                        echo "the account $MEMBERS has $role assigned to ORG"
					 IFS=$'\n' read -rd "" -a y <<< "$MEMBERS"
                                         for abc3 in "${y[@]}"; do
                                           echo "$abc3, Organization_$ORG_ID" >> temp_relations.txt
                                         done
					#echo "$MEMBERS, Organization_$ORG_ID" >> temp_relations.txt
	  fi

 done

#echo "List of identified custom roles at ORG level"
#for element in "${TARGET_ROLES[@]}"; do
# printf "%s\n" "$element"
#done
