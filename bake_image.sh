BASENAME="tezos_build"
DOCKERHUB_REPO=$BASENAME"_deps"
TAG=latest
IMAGE_FULLNAME=$DOCKERHUB_REPO:$TAG

DOCKERHUB_NAME=${1:-sgtn}
ORG=${2:-cryptoeconomicslab}
BRANCH=${3:-@sg/michelson-level}
echo "Dockerhub Target = $DOCKERHUB_NAME/$DOCKERHUB_REPO"
echo "Tezos Target = $ORG/tezos#$BRANCH"


[ ! -d "./tezos" ] && git clone git@gitlab.com:$ORG/tezos.git
if [ -d "./tezos" ]; then
  cd tezos
  git checkout $BRANCH
  cd ../
fi

docker image build -t $IMAGE_FULLNAME --ulimit nofile=1024 .
IMAGES_RAW=`docker images`

if [[ $IMAGES_RAW == *$DOCKERHUB_REPO*$TAG* ]]; then
  echo "=== Tezos dockerized. ==="
  cd ./tezos
  scripts/ci/create_docker_image.build.sh $DOCKERHUB_NAME/$BASENAME
  docker push $IMAGE_FULLNAME
  cd ../
else
 echo "Tezos dockerization failed."
fi
