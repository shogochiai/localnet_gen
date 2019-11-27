export DATA_DIR=/tmp/sandboxdatatz && mkdir -p $DATA_DIR
./src/bin_node/tezos-sandboxed-node.sh 1 --connections 1 &>/dev/null &
eval `./src/bin_client/tezos-init-sandboxed-client.sh 1`
tezos-activate-alpha
tezos-baker-alpha run with local node $DATA_DIR &>/dev/null &