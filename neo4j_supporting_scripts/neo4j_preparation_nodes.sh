#!/bin/bash

declare -a NUMBERS_NODES=()
while IFS= read -r line; do
   NUMBERS_NODES+=("$line")
done < $1
counter=0;
echo "id, nodes" >> $2
for node_line in "${NUMBERS_NODES[@]}"; do
  let counter=counter+1;
  echo "$counter, $node_line" >> $2
done

