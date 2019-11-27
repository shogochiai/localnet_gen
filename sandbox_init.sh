export DATA_DIR=/tmp/sandboxdatatz
./src/bin_node/tezos-sandboxed-node.sh 1 --connections 1 &>/dev/null &
eval `./src/bin_client/tezos-init-sandboxed-client.sh 1`
tezos-client rpc get /chains/main/blocks/head/metadata
tezos-activate-alpha
tezos-client list known addresses
tezos-baker-alpha -P 18731 run with local node 
tezos-autocomplete
