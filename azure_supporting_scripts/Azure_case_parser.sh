#!/bin/bash
#MB2024
echo "script parsing csv files for Azure graph generation"

echo "Parsing Service Principals..."
python ServicePrincipal_Permissions_csv_parser.py ServicePrincipalRolesv2.csv serviceprincipals_scope_relations.csv
python concatSP.py serviceprincipals_scope_relations.csv relation_sp_scopes.csv
echo "Groups..."
python GroupRolesPermissions_csv_parser.py GroupRolesPermissions.csv groups_scope_relations.csv
python concatGR.py groups_scope_relations.csv relation_groups_scopes.csv
python GroupMembers_csv_parser.py GroupMembers.csv group_members_relations.csv
python concatGRMEM.py group_members_relations.csv relation_groups_members.csv
echo "Users..."
python UserRolesPermissions_csv_parser.py UserRolesPermissions.csv users_scopes_relations.csv
python concatUser.py users_scopes_relations.csv relation_users_scopes.csv

sed '1d' relation_sp_scopes.csv > ralation_sp_scopes_2.csv
sed '1d' relation_groups_scopes.csv > relation_groups_scopes_2.csv
sed '1d' relation_groups_members.csv > relation_groups_members_2.csv
sed '1d' relation_users_scopes.csv > relation_users_scopes_2.csv

rm nodes_temp.csv
cut -d',' -f1 *_2.csv >> nodes_temp.csv
cut -d',' -f2 *_2.csv >> nodes_temp.csv
cat relation_sp_scopes_2.csv relation_groups_scopes_2.csv relation_users_scopes_2.csv > relations_temp.csv


uniq nodes_temp.csv > nodes.csv
uniq relations_temp.csv > relations_all.csv
uniq relation_groups_members_2.csv > relations_members.csv


