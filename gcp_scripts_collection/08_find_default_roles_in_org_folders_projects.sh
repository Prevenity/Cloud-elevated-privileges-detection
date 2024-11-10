#!/bin/bash
#MB2023
#check ID of Organization and store ORG_ID

#ORG_ID=$(gcloud organizations list --format="value(name)")
ORG_ID=$1

declare -a TARGET_FOLDERS=()
declare -a TARGET_ROLES=()
declare -a TARGET_PROJECTS=()

# Fetch the list of project IDs
projects_list=$(gcloud projects list --format="value(projectId)")

# Convert the newline-separated list of projects to an array
projects_array=($projects_list)

for element in "${projects_array[@]}"; do
        if [[ $element != sys-* ]]; then
                TARGET_PROJECTS+=($element)
        fi
done

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

delimeter=";"
values_final=()
IFS="$delimeter"
read -ra values_final <<< "$TARGET_FOLDERS"

# To store roles with desired permissions

#echo "Loading roles from file..."
delimeter=" "
IFS="$delimeter"
while IFS= read -d ' ' element; do
  TARGET_ROLES+=("$element")
done < temp_file_with_default_roles_containing_high_priveleges.txt
#=====================================
#default roles at org level
echo "Collecting data from ORG $ORG_ID"
POLICY=$(gcloud organizations get-iam-policy $ORG_ID --format=json)

      for target_role in $TARGET_ROLES;do
        #
        MEMBERS=$(echo $POLICY | jq --arg role "$target_role" '.bindings[] | select(.role == $role) | .members[]')
        if [ ! -z "$MEMBERS" ]; then
                  echo "Account $MEMBERS in org $ORG_ID has role $target_role"
                  echo "-----------"
			            IFS=$'\n' read -rd "" -a y <<< "$MEMBERS"
                                         for abc3 in "${y[@]}"; do
                                           echo "$abc3, Organization_$ORG_ID" >> temp_relations.txt
                                         done
        fi
      done
#======================================
#default roles at folder level
echo "Collecting data from folders"
 for folder in "${values_final[@]}"; do
   POLICY=$(gcloud resource-manager folders get-iam-policy $folder --format=json)
      for target_role in $TARGET_ROLES;do
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

#========================================
#default roles at project level //projects enumerate users and service accounts
echo "Collecting data for projects"
for project in "${TARGET_PROJECTS[@]}"; do
   POLICY=$(gcloud projects get-iam-policy $project --format=json)
      for target_role in $TARGET_ROLES;do
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


