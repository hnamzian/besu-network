#!/bin/bash

BESU_CONS_ALGO="IBFT"
BESU_CONFIG_FILE="./config/ibftConfig.json"
BESU_CONFIG_PATH="./config/networkFiles"
BESU_GENESIS_PATH="./config/besu"
BESU_NODES_PATH="./config/nodes"
BESU_PERMISSIONS_CONFIG_PATH="./config/besu/permissions_config.toml"
BESU_STATIC_NODES_CONFIG_PATH="./config/besu/static-nodes.json"
BESU_CONFIG_FILE_PATH="./config/besu/config.toml"

declare -a BESU_NODE_NAMES=("validator1" "validator2" "validator3" "validator4" "rpcnode")
declare -a BESU_BOOT_NODES_NAMES=("validator1")
declare -a BESU_NODE_URLs=("172.16.239.11:30303" "172.16.239.12:30303" "172.16.239.13:30303" "172.16.239.14:30303" "172.16.239.15:30303")

generate_network_genesis_and_keys() {
  besu operator generate-blockchain-config \
    --config-file=$BESU_CONFIG_FILE\
    --to=$BESU_CONFIG_PATH \
    --private-key-file-name=key

  mv $BESU_CONFIG_PATH/genesis.json $BESU_GENESIS_PATH/${BESU_CONS_ALGO}genesis.json

  mkdir $BESU_NODES_PATH

  NODES=($(ls $BESU_CONFIG_PATH/keys))
  length=${#NODES[@]}

  for (( j=0; j<length; j++ ));
  do
    mkdir -p $BESU_NODES_PATH/"${BESU_NODE_NAMES[$j]}"
    sed 's/0x//' $BESU_CONFIG_PATH/keys/${NODES[$j]}/key > $BESU_NODES_PATH/"${BESU_NODE_NAMES[$j]}"/nodekey
    sed 's/0x//' $BESU_CONFIG_PATH/keys/${NODES[$j]}/key.pub > $BESU_NODES_PATH/"${BESU_NODE_NAMES[$j]}"/nodekey.pub
    (printf "${NODES[$j]}" > $BESU_NODES_PATH/"${BESU_NODE_NAMES[$j]}"/address)
  done

  rm -rf $BESU_CONFIG_PATH
}

generate_permissions_config() {
  NODES=($(ls $BESU_NODES_PATH))
  length=${#NODES[@]}

  (printf "nodes-allowlist=[" > $BESU_PERMISSIONS_CONFIG_PATH)

  for (( j=0; j<length; j++ ));
  do
    pub_key=$(cat $BESU_NODES_PATH/${BESU_NODE_NAMES[$j]}/nodekey.pub)
    new_enode_url="enode://$pub_key@"${BESU_NODE_URLs[$j]}""
    (printf "\n\"$new_enode_url\"," >> $BESU_PERMISSIONS_CONFIG_PATH)
  done

  (printf "\n]" >> $BESU_PERMISSIONS_CONFIG_PATH)
}

generate_static_nodes_config() {
  NODES=($(ls $BESU_NODES_PATH))
  length=${#NODES[@]}

  (printf "[" > $BESU_STATIC_NODES_CONFIG_PATH)

  for (( j=0; j<length; j++ ));
  do
    delimitter=","
    if [[ $j -eq $(( $length - 1 )) ]]
      then 
        delimitter="\n]"
      fi

    pub_key=$(cat $BESU_NODES_PATH/"${BESU_NODE_NAMES[$j]}"/nodekey.pub)
    new_enode_url="enode://$pub_key@"${BESU_NODE_URLs[$j]}""
    (printf "\n\"$new_enode_url\"$delimitter" >> $BESU_STATIC_NODES_CONFIG_PATH)
  done
}

update_boot_node_configs() {
  length=${#BESU_BOOT_NODES_NAMES[@]}

  boot_nodes="["

  for (( j=0; j<length; j++ ));
  do
    delimitter=","
    if [[ $j -eq $(( $length - 1 )) ]]
      then 
        delimitter="]"
      fi

    pub_key=$(cat $BESU_NODES_PATH/"${BESU_NODE_NAMES[$j]}"/nodekey.pub)
    
    boot_node=$(cat $BESU_STATIC_NODES_CONFIG_PATH | jq '.[] | select(test("'$pub_key'"))')
    boot_nodes=$boot_nodes$boot_node$delimitter
  done

  TARGET_KEY="bootnodes="
  sed -i "s+\($TARGET_KEY\).*+\1$boot_nodes+" $BESU_CONFIG_FILE_PATH
}


echo [BESU] Generate genesis and nodes private keys
generate_network_genesis_and_keys

echo [BESU] Generate Permissions config file
generate_permissions_config

echo [BESU] Generate static nodes config
generate_static_nodes_config

echo [BESU] Update boot nodes of config file
update_boot_node_configs