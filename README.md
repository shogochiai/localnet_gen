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