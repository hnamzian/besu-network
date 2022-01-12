#!/bin/bash

TEMPLATE_CCP_PATH="./scripts/connection_profile_template.json"
OUTPUT_CCP_DIR="./scripts/connection_profiles"
OUTPUT_CCP_NAME="connection_profile.json"
TESSERA_PUB_KEY_PATH="./config/nodes"

declare -a TESSERA_NODE_NAMES=("tessera1" "tessera2" "tessera3" "tessera4")
declare -a BESU_VALIDATOR_NAMES=("validator1")
declare -a BESU_VALIDATOR_URLS=("http://validator1:8545")

generate_connection_profile() {
  mkdir $OUTPUT_CCP_DIR
  OUTPUT_CCP_PATH=$OUTPUT_CCP_DIR/$OUTPUT_CCP_NAME
  cp $TEMPLATE_CCP_PATH $OUTPUT_CCP_PATH

  length=${#TESSERA_NODE_NAMES[@]}

  for (( j=0; j<length; j++ ));
  do
    jq '.network.tesseraPeers |= . + ["'${TESSERA_NODE_NAMES[$j]}'"]' $OUTPUT_CCP_PATH > tmp && mv tmp $OUTPUT_CCP_PATH

    pub_key=$(cat $TESSERA_PUB_KEY_PATH/"${TESSERA_NODE_NAMES[$j]}"/nodeKey.pub)
    jq '.tessera.'${TESSERA_NODE_NAMES[$j]}'.publicKey = "'${pub_key}'"' $OUTPUT_CCP_PATH > tmp && mv tmp $OUTPUT_CCP_PATH
  done

  length=${#BESU_VALIDATOR_NAMES[@]}

  for (( j=0; j<length; j++ ));
  do
    jq '.network.besuPeers |= . + ["'${BESU_VALIDATOR_NAMES[$j]}'"]' $OUTPUT_CCP_PATH > tmp && mv tmp $OUTPUT_CCP_PATH

    jq '.besu.'${BESU_VALIDATOR_NAMES[$j]}'.url = "'${BESU_VALIDATOR_URLS[$j]}'"' $OUTPUT_CCP_PATH > tmp && mv tmp $OUTPUT_CCP_PATH
  done
}

generate_connection_profile