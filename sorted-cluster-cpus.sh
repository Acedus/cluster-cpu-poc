#!/bin/bash

set -eou pipefail

mapfile -t node_char < <(kubectl get no -l kubevirt.io/schedulable=true -o json | jq -r '
  .items[] | 
  .metadata.name as $name |
  .metadata.labels | 
  with_entries(select(.key | startswith("host-model-required-features.node.kubevirt.io") or startswith("host-model-cpu.node.kubevirt.io"))) |
  to_entries | 
  map("\(.key)=\(.value)") | 
  sort | 
  join("|") |
  "\($name):\(.)"
')

declare -A node_groups

for node in "${node_char[@]}"; do
  IFS=':' read -r name characteristics <<< "$node"
  if [[ -z "${node_groups[$characteristics]+unset}" ]]; then
    node_groups["$characteristics"]="$name"
  else
    node_groups["$characteristics"]+=" $name"
  fi
done

for characteristics in "${!node_groups[@]}"; do
  first_node=$(echo "${node_groups[$characteristics]}" | awk '{print $1}')
  model=$(kubectl get no "$first_node" -o json | jq -r '.metadata.labels |
    keys[] |
    select(test("^host-model-cpu.node\\.kubevirt.io..*"))' -r | cut -d"/" -f2)
  count=$(echo "${node_groups[$characteristics]}" | wc -w)
  echo "$count $model ${node_groups[$characteristics]}"
done | sort -nr | column -t
