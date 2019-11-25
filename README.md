# Tezos Build Deps
- For MacOS users.
- Tezos dockerization script is somehow proprietary program.
- Tezos commands are depending on docker images and these often hard-coded in the bash scripts.
- Customized Tezos docker image is required to test protocol modification.
- Dockerfile of Tezos isn't shared hence I created this repo.

# Usage
- You must have git and docker on ur device.
- gitlab.com:tezos/tezos is private repo and so you need invitation on the repo.
- bake_image.sh is all

# Note
- If Tezos requires more than `opam 2.0.*`, please accordingly get it [by this command](https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
- You need enough storage for docker; otherwise, `make build-deps` will fail.

# Debug
- `<username>/tezos_deps`, `<username>/tezos_intermediate`, and `<username>/tezos` are the checkpoints of long build procedures. You can use skip/deepskip option to use such checkpoints.
- `tezos-node run` will show you the error inside tezos container. You can go inside via `./check_cointainer.sh`
  - `docker logs localnet_node_1` wouldn't show you enough information.