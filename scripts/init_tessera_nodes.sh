#!/bin/bash

TESSERA_NODES_PATH="./config/nodes"

declare -a TESSERA_NODE_NAMES=("ato-tessera" "4pillars-tessera" "lark-tessera" "bundaberg-tessera")

generate_tessera_keypairs() {
  length=${#TESSERA_NODE_NAMES[@]}

  for (( j=0; j<length; j++ ));
  do
    mkdir -p $TESSERA_NODES_PATH/"${TESSERA_NODE_NAMES[$j]}"
    echo "" | tessera keygen --keyout $PWD/config/nodes/"${TESSERA_NODE_NAMES[$j]}"/nodeKey
  done
}

generate_tessera_keypairs