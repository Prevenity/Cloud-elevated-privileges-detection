#!/bin/bash

declare -a CONFIRMED_ROLES=()
declare -a my_table=()
declare -a TARGET_PROJECTS=()
declare -a PERMISSIONS_TABLE=()

echo "all roles from org level"

# Enumerate and store org_id
#ORG_ID=$(gcloud organizations list --format="value(name)")
ORG_ID=$1

# Enumerate custom roles in org
#ALL_ROLES_ORG+=$(gcloud iam roles list --organization=$ORG_ID --format="value(name)" | cut -d'/' -f4)
ALL_ROLES_ORG+=$(gcloud iam roles list --organization=$ORG_ID --format="value(name)")
#echo " Roles at org level are $ALL_ROLES_ORG"

# Enumerate all projects and store

# Fetch the list of project IDs
projects_list+=$(gcloud projects list --format="value(projectId)")

# Convert the newline-separated list of projects to an array
projects_array=($projects_list)

for element in "${projects_array[@]}"; do
        if [[ $element != sys-* ]]; then
                TARGET_PROJECTS+=($element)
        fi
done

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

for project in "${TARGET_PROJECTS[@]}"; do
   
   #enumerate SA at org level
   ##### gcloud organizations get-iam-policy $ORG_ID --format=json
   POLICY=$(gcloud projects get-iam-policy $project --format=json)
      for target_role in "${TARGET_ROLES[@]}";do
        #
        MEMBERS=$(echo $POLICY | jq --arg role "$target_role" '.bindings[] | select(.role == $role) | .members[]')
        if [ ! -z "$MEMBERS" ]; then
                  echo "Account $MEMBERS in $project has role $target_role"
                  echo "-----------"
			IFS=$'\n' read -rd "" -a y <<< "$MEMBERS"
                                         for abc3 in "${y[@]}"; do
                                           echo "$abc3, $project" >> temp_relations.txt
                                         done


                 fi

      done


done
