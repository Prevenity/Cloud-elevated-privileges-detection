#!/bin/bash
#MB2024

tr -s ' ' ',' < serviceaccounts_namespaces.txt > sa2namespaces.txt
tr -s ' ' ',' < pods_namespaces.txt > pods2namespace.txt

jq -r '.items[] | [.metadata.name, .metadata.annotations["iam.gke.io/gcp-service-account"]] | @tsv' all_SA.json > serviceaccount_gkesa.txt
awk '{if ( NF == 2) print $1, $2}' serviceaccount_gkesa.txt > service2gkesa.txt

tr -s ' ' ',' < service2gkesa.txt > ksa2gkesa.txt

cut -d',' -f2 ksa2gkesa.txt > GKESA1_nodes.txt
cut -d',' -f2 sa2namespaces.txt > Namespaces.txt
cut -d',' -f2 pods2namespace.txt >> Namespaces.txt
cut -d',' -f1 pods2namespace.txt > PODS.txt
cut -d',' -f1 sa2namespaces.txt > KSA.txt 
cut -d',' -f1 ksa2gkesa.txt >> KSA.txt

cat KSA.txt|sort|uniq > ksa_nodes.txt
cat PODS.txt|sort|uniq > pods_nodes.txt
cat GKESA1_nodes.txt|sort|uniq > gkesa_nodes.txt
cat Namespaces.txt|sort|uniq > namespaces_nodes.txt

sed 's/,/, /g' ksa2gkesa.txt > 00_KSA_TO_GKESA.txt
sed 's/,/, /g' sa2namespaces.txt > 00_KSA_TO_NAMESPACE.txt
sed 's/,/, /g' pods2namespace.txt > 00_POD_TO_NAMESPACE.txt

sed '1d' ksa_nodes.txt > 01_ksa_nodes.txt
sed '1d' pods_nodes.txt > 01_pod_nodes.txt
mv gkesa_nodes.txt 01_gkesa_nodes.txt
sed '1d' namespaces_nodes.txt > 01_namespace_nodes.txt
