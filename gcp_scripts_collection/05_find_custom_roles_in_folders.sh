#!/bin/bash

declare -a CONFIRMED_ROLES=()
declare -a my_table=()
declare -a PERMISSIONS_TABLE=()

echo "all roles from org level"

# Enumerate and store org_id
#ORG_ID=$(gcloud organizations list --format="value(name)")
ORG_ID=$1

# Enumerate custom roles in org
#ALL_ROLES_ORG+=$(gcloud iam roles list --organization=$ORG_ID --format="value(name)" | cut -d'/' -f4)
ALL_ROLES_ORG+=$(gcloud iam roles list --organization=$ORG_ID --format="value(name)")
#echo "List of custom roles at org level $ALL_ROLES_ORG"

# Collecting info about folders

list_subfolders() {

  local parent_folder=$1
  local folders

  # List folders directly under the parent folder
  folders=$(gcloud resource-manager folders list --folder="$parent_folder" --format="value(name)")
  for folder in $folders; do
    TARGET_FOLDERS+="$folder;"
    # Recursively list subfolders
    list_subfolders "$folder"
  done
}

folders_id+=$(gcloud resource-manager folders list --organization=$ORG_ID --format="value(name)")

 for folderx in $folders_id; do
  TARGET_FOLDERS+="$folderx;"
  list_subfolders "$folderx"
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

delimeter=";"
values_final=()
IFS="$delimeter"
read -ra values_final <<< "$TARGET_FOLDERS"

 for folder in "${values_final[@]}"; do

   POLICY=$(gcloud resource-manager folders get-iam-policy $folder --format=json)

      for target_role in "${TARGET_ROLES[@]}";do
        #
        MEMBERS=$(echo $POLICY | jq --arg role "$target_role" '.bindings[] | select(.role == $role) | .members[]')
	if [ ! -z "$MEMBERS" ]; then
                  echo "Account $MEMBERS in $folder has role $target_role"
                  echo "-----------"
              		IFS=$'\n' read -rd "" -a y <<< "$MEMBERS"
                                         for abc3 in "${y[@]}"; do
                                           echo "$abc3, Folder_$folder" >> temp_relations.txt
                                         done
                 fi



      done

 done
