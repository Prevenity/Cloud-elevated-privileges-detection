#!/bin/bash

declare -a CONFIRMED_ROLES=()
declare -a my_table=()
declare -a TARGET_PROJECTS=()
declare -a PERMISSIONS_TABLE=()

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

#for element in "${projects_array[@]}"; do
#  printf "%s\n" "$element"
#done

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
    echo $SHORT_ROLE_NAME
    PERMISSIONS=$(gcloud iam roles describe $SHORT_ROLE_NAME --format="value(includedPermissions)"  --organization=$ORG_ID)

	 for permission in ${PERMISSIONS_TABLE[@]}; do
                if [[ $PERMISSIONS == *$permission* ]]; then
                        echo "Role $role has permission $permission"
                        TARGET_ROLES+=("$role")
                fi
        done
done
echo "START"
echo $TARGET_ROLES
for testxxx in "${TARGET_ROLES[@]}"; do
 printf "%s\n" "$testxxx"
done
echo "END"

for project in "${TARGET_PROJECTS[@]}"; do
        echo " Extracting all SA in project $project ..."
        # Enumerate service accounts (project onlynow)
        SERVICE_ACCOUNTS=$(gcloud iam service-accounts list --format="value(email)" --project=$project)
           for sa in $SERVICE_ACCOUNTS; do
             # Get IAM policy for each service account and search for roles with desired permissions
	     echo "part related to extracting sa"
	     echo $sa
             BINDINGS=$(gcloud iam service-accounts get-iam-policy $sa --format=json --project=$project)
	
               for target_role in "${TARGET_ROLES[@]}"; do
	        echo $target_role
               # Using jq to parse and query JSON. Assumes jq is available.
                 if [ ! -z "$BINDINGS" ]; then
                   MEMBERS=$(echo $BINDINGS | jq --raw-output -r --arg role "$target_role" '.bindings[] | select(.role == $role) | .members[]' 2>/dev/null)
                  if [ ! -z "$MEMBERS" ]; then
                  echo "Service account $sa in $project has role $target_role assigned to:"
                  echo "$MEMBERS"
                  echo "-----------"
				
                  IFS=$'\n' read -rd "" -a y <<< "$MEMBERS"
                                         for abc3 in "${y[@]}"; do
                                           echo "$abc3, $sa" >> temp_relations.txt
                                         done
                  fi
                 fi
               done
            done


done

