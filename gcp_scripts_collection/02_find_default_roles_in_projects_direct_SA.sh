#!/bin/bash

# To store roles with desired permissions
declare -a TARGET_ROLES=()
declare -a PERMISSIONS_TABLE=()
declare -a TARGET_PROJECTS=()

# load file with roles
echo "Loading roles from file..."
while IFS= read -d ' ' element; do
  TARGET_ROLES+=("$element")
done < temp_file_with_default_roles_containing_high_priveleges.txt

# Enumerate all projects 

# Fetch the list of project IDs
projects_list=$(gcloud projects list --format="value(projectId)")

# Convert the newline-separated list of projects to an array
projects_array=($projects_list)

for element in "${projects_array[@]}"; do
	if [[ $element != sys-* ]]; then
		TARGET_PROJECTS+=($element)
	fi
done

for project in "${TARGET_PROJECTS[@]}"; do
   

	#echo " Extracting all SA in project $project ..."
        # Enumerate service accounts (project onlynow)
        SERVICE_ACCOUNTS=$(gcloud iam service-accounts list --format="value(email)" --project=$project)
           for sa in $SERVICE_ACCOUNTS; do
             echo "Extracted SA name $sa"
             # Get IAM policy for each service account and search for roles with desired permissions
             #echo "Checking bindings for $sa ..."
             BINDINGS=$(gcloud iam service-accounts get-iam-policy $sa --format=json --project=$project)
	     #echo "$BINDINGS"
               for target_role in $TARGET_ROLES; do
               # Using jq to parse and query JSON. Assumes jq is available.
               if [ ! -z "$BINDINGS" ]; then
	       MEMBERS=$(echo $BINDINGS | jq --raw-output -r --arg role "$target_role" '.bindings[] | select(.role == $role) | .members[]' 2>/dev/null)
		#MEMBERS=$(echo $BINDINGS | jq --raw-output -r --arg role "$target_role" '.bindings[] | select(.role == $role) | .members[]')
	       #echo "$MEMBERS"
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



