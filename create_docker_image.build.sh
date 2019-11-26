#! /bin/sh

set -e

ci_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
script_dir="$(dirname "$ci_dir")"
src_dir="$(dirname "$script_dir")"
cd "$src_dir"

. "$script_dir"/version.sh

tmp_dir=$(mktemp -dt tezos.opam.tezos.XXXXXXXX)

cleanup () {
    set +e
    echo Cleaning up...
    rm -rf "$tmp_dir"
    rm -rf Dockerfile
}
trap cleanup EXIT INT

image_name="${1:-tezos_build}"
image_version="latest"
base_image="${image_name}_deps:${image_version}"
intermediate_image="${image_name}_deps_intermediate:${image_version}"
SKIP=${2:-skip}

mkdir -p "$tmp_dir"/tezos/scripts
cp -a Makefile "$tmp_dir"/tezos
cp -a active_protocol_versions "$tmp_dir"/tezos
cp -a scripts/alphanet_version "$tmp_dir"/tezos/scripts/
cp -a scripts/docker/entrypoint.sh "$tmp_dir"/tezos/scripts/
cp -a scripts/docker/entrypoint.inc.sh "$tmp_dir"/tezos/scripts/
cp -a scripts/version.sh "$tmp_dir"/tezos/scripts/
cp -a scripts/install_build_deps.sh "$tmp_dir"/tezos/scripts/
cp -a scripts/install_build_deps.raw.sh "$tmp_dir"/tezos/scripts/
cp -a src "$tmp_dir"/tezos
cp -a vendors "$tmp_dir"/tezos

########
# build-deps caching
########
cat <<EOF > "$tmp_dir"/Dockerfile
FROM $base_image
RUN ls
COPY --chown=tezos:nogroup tezos tezos
ENV PATH $PATH:/usr/local/tezos
RUN mkdir -p /usr/local/share/tezos
RUN echo "alpha" > /usr/local/share/tezos/active_protocol_versions
WORKDIR ./tezos
RUN opam exec -- make build-deps
EOF


if [ "$SKIP" != "deepskip" ]; then
    echo
    echo "### Building tezos-intermediate..."
    echo
    docker build -t $intermediate_image "$tmp_dir"
    docker push $intermediate_image
    echo
    echo "### Successfully build docker image: $intermediate_image"
    echo
else 
    echo "### Tezos Intermediate is deepskipped."
fi



#######
# Tezos image by using build-deps cache
#######
cat <<EOF > "$tmp_dir"/Dockerfile
FROM $intermediate_image
RUN opam exec -- make all
RUN apt-get -y install sudo
RUN cp ./scripts/alphanet_version /usr/local/share/tezos/alphanet_version
RUN cp ./tezos-node /usr/local/bin/tezos-node
RUN cp ./tezos-baker-alpha /usr/local/bin/tezos-baker
RUN cp ./tezos-accuser-alpha /usr/local/bin/tezos-accuser
RUN cp ./tezos-endorser-alpha /usr/local/bin/tezos-endorser
RUN cp ./tezos-baker-alpha ./tezos-baker
RUN cp ./tezos-accuser-alpha ./tezos-accuser
RUN cp ./tezos-endorser-alpha ./tezos-endorser
RUN echo "./localnet.sh" > /usr/local/share/tezos/alphanet.sh
RUN tezos-node identity generate 0
RUN echo "http		80/tcp		www		# WorldWideWeb HTTP" > /etc/services
EOF

echo
echo "### Building tezos..."
echo

docker build -t "$image_name:$image_version" "$tmp_dir"

echo
echo "### Successfully build docker image: $image_name:$image_version"
echo