#!/bin/bash

TESSERA_NODES_PATH="./config/nodes"

declare -a TESSERA_NODE_NAMES=("tessera1" "tessera2" "tessera3" "tessera4")

generate_tessera_keypairs() {
  length=${#TESSERA_NODE_NAMES[@]}

  for (( j=0; j<length; j++ ));
  do
    mkdir -p $TESSERA_NODES_PATH/"${TESSERA_NODE_NAMES[$j]}"
    tessera keygen --keyout $PWD/config/nodes/"${TESSERA_NODE_NAMES[$j]}"/nodeKey
  done
}

generate_tessera_keypairs