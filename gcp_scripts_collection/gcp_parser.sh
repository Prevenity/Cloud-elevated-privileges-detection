#!/bin/bash
#MB 2023

echo "Automation script 1.0"
echo "Input: ORG_ID"
echo "Output: two csv files which can be imported to neo4j"
echo "jq tool is required!"


rm temp_relations.txt 2>/dev/null
rm relations.txt 2>/dev/null
rm temp_nodes.txt 2>/dev/null
rm temp_nodes2.txt 2>/dev/null
rm nodes_neo4j.csv 2>/dev/null
rm relations_neo4j.csv 2>/dev/null
rm nodes.txt 2>/dev/null
rm relations00.txt 2>/dev/null

if [ ! -z "$1" ]; then

echo "ORG ID is $1"

else
 echo "Please provide correct ORG ID"
fi


#./01_collect_default_roles_with_high_privileges.sh #If the list of permissions you are looking for is the same, you only need to run this script once.
./02_find_default_roles_in_projects_direct_SA.sh
./03_find_custom_roles_in_proj.sh $1
./04_find_custom_roles_at_org_level.sh $1
./05_find_custom_roles_in_folders.sh $1
./06_find_custom_org_roles_at_direct_projects.sh $1
./07_find_custom_org_roles_at_projects.sh $1
./07a_find_custom_roles_at_projects.sh $1
./08_find_default_roles_in_org_folders_projects.sh $1

#remove some prefixes

prefix1="user:"
prefix2="group:"
prefix3="serviceAccount"



cat temp_relations.txt | tr -d "\"" > temp_relations2.txt

declare -a TABLE=()
while IFS= read -r line; do
  TABLE+=("$line")
done < temp_relations2.txt

for abcd in "${TABLE[@]}"; do
   
  if [[ $abcd == user* ]]
  then
        echo "${abcd#"user:"}" >> relations.txt
        continue
  fi
  if [[ $abcd == group* ]]
  then
        echo "${abcd#"group:"}" >> relations.txt
        continue
  fi
  if [[ $abcd == serviceAccount* ]]
  then
        echo "${abcd#"serviceAccount:"}" >> relations.txt
        continue
  fi
 printf "remaining relation: %s\n" "$abcd"
done



#create nodes file.

declare -a NODES=()
while IFS= read -d ' ' element; do
  NODES+=("$element")
done < temp_relations2.txt


for element2 in "${NODES[@]}"; do
  echo "${element2//,}" >> temp_nodes.txt 
done

cat temp_nodes.txt | cut -d : -f2 > temp_nodes2.txt
cat temp_nodes2.txt | sort | uniq > nodes.txt

cat relations.txt | sort | uniq > relations00.txt

#prepare for neo4j
#
declare -a NUMBERS_NODES=()
while IFS= read -r line; do
   NUMBERS_NODES+=("$line")
done < nodes.txt
counter=0;
echo "id, nodes" >> nodes_neo4j.csv
for node_line in "${NUMBERS_NODES[@]}"; do
  let counter=counter+1;
  echo "$counter, $node_line" >> nodes_neo4j.csv
done

declare -a NUMBERS_RELATIONS=()
while IFS= read -r line; do
   NUMBERS_RELATIONS+=("$line")
done < relations00.txt
counter=0;
echo "id, source, destination" >> relations_neo4j.csv
for node_line in "${NUMBERS_RELATIONS[@]}"; do
  let counter=counter+1;
  echo "$counter, $node_line" >> relations_neo4j.csv
done








