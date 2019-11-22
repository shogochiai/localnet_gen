###################
# Constants
###################
BASENAME="tezos_build"
DOCKERHUB_REPO=$BASENAME"_deps"
TAG=latest
IMAGE_FULLNAME=$DOCKERHUB_REPO:$TAG

###################
# Prepare dockerhub info
###################
DOCKERHUB_NAME=${1:-sgtn}
echo "DOCKERHUB_PASS: " && read -s DOCKERHUB_PASS
export DOCKER_HUB_USERNAME=$DOCKERHUB_NAME
export DOCKER_HUB_PASSWORD=$DOCKERHUB_PASS

###################
# Check docker-hub command and install
###################
if ! [ -x "$(command -v docker-hub)" ]; then
  echo 'Error: docker-hub is not installed.' >&2
  pip install docker-hub
fi

###################
# Fetch your dockerhub repos
###################
repos=`docker-hub repos --orgname $DOCKERHUB_NAME`

###################
# Check target dockerhub repo is already created or not
###################
if [[ $repos == *$DOCKERHUB_REPO* ]]; then
  echo "$DOCKERHUB_REPO is already in your dockerhub"
else
  echo "Please add $DOCKERHUB_REPO in your dockerhub repos."
  exit 1
fi

###################
# Explain what will happen
###################
ORG=${2:-cryptoeconomicslab}
BRANCH=${3:-@sg/michelson-level}
echo "Dockerhub Target = $DOCKERHUB_NAME/$DOCKERHUB_REPO"
echo "Tezos Target = $ORG/tezos#$BRANCH"

###################
# Clone Tezos Repo
###################
[ ! -d "./tezos" ] && git clone git@gitlab.com:$ORG/tezos.git

###################
# Checkout to the target custom branch
###################
if [ -d "./tezos" ]; then
  cd tezos
  git checkout $BRANCH
  cd ../
fi

###################
# Build docker image of basic Tezos env
###################
docker image build -t $IMAGE_FULLNAME --ulimit nofile=1024 .


###################
# Get built images
###################
IMAGES_RAW=`docker images`

###################
# Check target image
###################
if [[ $IMAGES_RAW == *$DOCKERHUB_REPO*$TAG* ]]; then
  echo "=== Tezos dockerized. ==="
  cd ./tezos

  ###################
  # Build custom Tezos inside docker
  ###################
  scripts/ci/create_docker_image.build.sh $DOCKERHUB_NAME/$BASENAME

  ###################
  # Push it to Dockerhub
  ###################
  docker push $IMAGE_FULLNAME
  cd ../
else
 echo "Tezos dockerization failed."
fi
