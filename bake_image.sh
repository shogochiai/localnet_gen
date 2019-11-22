[ ! -d "./tezos" ] && git clone git@gitlab.com:tezos/tezos.git
DC_REPO_SHORT="tezos_build"
DC_TAG=$DC_REPO_SHORT"_deps:latest"
docker image build -t $DC_TAG --ulimit nofile=1024 .
DC_RES=`docker images`
if [[ $DC_RES == *$DC_TAG* ]]; then
  echo "=== Tezos dockerized. ==="
  cd ./tezos
  scripts/ci/create_docker_image.build.sh sgtn/$DC_REPO_SHORT
  cd ../
else
 echo "Tezos dockerization failed."
fi
