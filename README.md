# Tezos Build Deps
- For MacOS users.
- Tezos dockerization script is somehow proprietary program.
- Tezos commands are depending on docker images and these often hard-coded in the bash scripts.
- Customized Tezos docker image is required to test protocol modification.
- Dockerfile of Tezos isn't shared hence I created this repo.

# Usage
- `./start` and input Dockerhub Password
- export DATA_DIR=/tmp/sandboxdatatz && mkdir -p $DATA_DIR
- ./src/bin_node/tezos-sandboxed-node.sh 1 --connections 1 &>/dev/null &
- eval `./src/bin_client/tezos-init-sandboxed-client.sh 1`
- tezos-activate-alpha
- tezos-baker-alpha run with local node $DATA_DIR &>/dev/null &
- sandbox_deploy_level_lock.sh

# Note
- You need enough storage for docker; otherwise, `make build-deps` will fail.

# Debug
- `bake_localnet.sh` has `skip` and `deepskip` option. `./start` has `skip` option. Build is long way.
- `<username>/tezos_deps`, `<username>/tezos_intermediate`, and `<username>/tezos` are the checkpoints of long build procedures. You can use skip/deepskip option to use such checkpoints.
- `tezos-node run` will show you the error inside tezos container. You can go inside via `./check_cointainer.sh`
  - `docker logs localnet_node_1` wouldn't show you enough information.