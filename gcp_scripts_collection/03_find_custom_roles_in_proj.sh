#!/bin/bash

declare -a CONFIRMED_ROLES=()
declare my_table=()
declare -a TARGET_PROJECTS=()
declare -a PERMISSIONS_TABLE=()
declare -a ALL_ROLES_ORG_LINES=()

# Enumerate and store org_id
#ORG_ID=$(gcloud organizations list --format="value(name)")
ORG_ID=$1

# Enumerate custom roles in org
ALL_ROLES_ORG+=$(gcloud iam roles list --organization=$ORG_ID --format="value(name)" | cut -d'/' -f4)
#echo " Roles are $ALL_ROLES_ORG"
IFS=$'\n' read -rd "" -a ALL_ROLES_ORG_LINES <<< "$ALL_ROLES_ORG"

# Enumerate all projects and store 

# Fetch the list of project IDs
#projects_list+=$(gcloud projects list --format="value(projectId)")
projects_list=$(gcloud asset search-all-resources --asset-types="cloudresourcemanager.googleapis.com/Project" --scope=organizations/$1 --format="value(additionalAttributes.projectId)")

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


 
 for project in "${TARGET_PROJECTS[@]}"; do
  ALL_ROLES_PROJ=$(gcloud iam roles list --project=$project --format="value(name)")
  #echo ${ALL_ROLES_PROJ[@]}
  
  IFS=$'\n' read -rd "" -a ALL_ROLES_PROJ_LINES <<< "$ALL_ROLES_PROJ"
 
  for role in "${ALL_ROLES_PROJ_LINES[@]}"; do
    echo "Checking $role in project:  $project"

    SHORT_ROLE_NAME=$(echo $role | cut -d'/' -f4)
    echo "Short name is: $SHORT_ROLE_NAME "

    # Get permissions for role and search for the specified permissions
    PERMISSIONS=$(gcloud iam roles describe $SHORT_ROLE_NAME --format="value(includedPermissions)" --project=$project)
    for permission in ${PERMISSIONS_TABLE[@]}; do
     if [[ $PERMISSIONS = *$permission* ]]; then
        echo "Role $role has permission $permission"
        TARGET_ROLES+=("$role")
        SERVICE_ACCOUNTS=$(gcloud iam service-accounts list --format="value(email)" --project=$project)
                for sa in $SERVICE_ACCOUNTS; do
                        # Get IAM policy for each service account and search for roles with desired permissions
                        BINDINGS=$(gcloud iam service-accounts get-iam-policy $sa --format=json --project=$project)
                        #mytable2=$(echo $BINDINGS | jq -r --arg role '$role' '.bindings[] | select(.role == $role) | .members[]')
			my_table=$(echo $BINDINGS | jq --raw-output -r --arg role "$role" '.bindings[] | select(.role == $role) | .members[]' 2>/dev/null)
			
                                if [ ! -z "$my_table" ]; then
                                        echo "Service account $sa in $project has role $role assigned to:"
                                        echo "$my_table"
                                        echo "----"
					 IFS=$'\n' read -rd "" -a y <<< "$my_table"
                                         for abc3 in "${y[@]}"; do
                                           echo "$abc3, $sa" >> temp_relations.txt
                                         done

						


                                fi

                done
    fi

  done





  done

 done

#echo "List of project custom roles with high permissions:"
#for element in "${TARGET_ROLES[@]}"; do
#  printf "%s\n" "$element"
#done
