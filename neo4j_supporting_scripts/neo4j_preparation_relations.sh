#!/bin/bash

declare -a NUMBERS_RELATIONS=()
while IFS= read -r line; do
   NUMBERS_RELATIONS+=("$line")
done < $1
counter=0;
echo "id, source, destination" >> $2
for node_line in "${NUMBERS_RELATIONS[@]}"; do
  let counter=counter+1;
  echo "$counter, $node_line" >> $2
done


