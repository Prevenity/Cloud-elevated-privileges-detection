#!/bin/bash
#MB2024
echo "Collecting detailed info about SA"
kubectl get serviceaccounts -A -o json > all_SA.json

echo "Collecting info about pods and namespaces"
kubectl get pods -A -o custom-columns=Name:.metadata.name,Namespace:.metadata.namespace > pods_namespaces.txt

echo "Collecting info about SA and namespaces"
kubectl get serviceaccounts --all-namespaces -o custom-columns=Name:.metadata.name,Namespace:.metadata.namespace > serviceaccounts_namespaces.txt
