###################
# Constants
###################
BASENAME="tezos_build"
DOCKERHUB_BARE_REPO=$BASENAME"_deps"
DOCKERHUB_COMPLETED_REPO=tezos
TAG=latest
IMAGE_FULLNAME=$DOCKERHUB_BARE_REPO:$TAG

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
hubcount=0
[[ $repos != *" "$DOCKERHUB_BARE_REPO" "* ]] && hubcount=$(($hubcount+1))
[[ $repos != *" "$DOCKERHUB_COMPLETED_REPO" "* ]] && hubcount=$(($hubcount+1))
[ "$hubcount" -gt "0" ] && echo "Please add $DOCKERHUB_BARE_REPO and $DOCKERHUB_COMPLETED_REPO in your dockerhub repos." && exit 1

###################
# Explain what will happen
###################
ORG=${2:-cryptoeconomicslab}
BRANCH=${3:-@sg/michelson-level}
echo "Dockerhub Target = $DOCKERHUB_NAME/$DOCKERHUB_BARE_REPO"
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
if [[ $IMAGES_RAW == *$DOCKERHUB_BARE_REPO*$TAG* ]]; then
  echo "=== Tezos Bare dockerized. ==="
  ###################
  # Push bare image to Dockerhub
  ###################
  docker push $DOCKERHUB_NAME/$IMAGE_FULLNAME

  ###################
  # Build custom Tezos inside docker
  ###################
  cd ./tezos
  scripts/ci/create_docker_image.build.sh $DOCKERHUB_NAME/$BASENAME
  cd ../

  ###################
  # Push completed image to Dockerhub
  ###################
  docker push $DOCKERHUB_NAME/$DOCKERHUB_COMPLETED_REPO:latest
  echo "=== Tezos Bare dockerized. ==="
else
 echo "Tezos dockerization failed."
fi
