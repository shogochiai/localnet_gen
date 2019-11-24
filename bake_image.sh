#!/bin/bash

###
# !!! Read Me !!!
#
# ./bake_image.sh SKIP_BARE DOCKERHUB_NAME ORG BRANCH
#
# # Args
# 1. "skip" flag
# 2. DOCKERHUB_NAME default=sgtn
# 3. (Gitlab's Tezos Fork's)ORG default=cryptoeconomicslab
# 4. BRANCH default=@sg/michelson-level
#
# # Preparation
# ex1. You must input dockerhub pass into secret read dialog
# ex2. You must have tezos_build_deps and tezos repos in dockerhub beforehand
###


###################
# Constants
###################
SKIP=${1:-skip}
DOCKERHUB_NAME=${2:-sgtn}
BASENAME="tezos"
DOCKERHUB_BARE_REPO_body=$BASENAME"_deps"
DOCKERHUB_COMPLETED_REPO_body=tezos
DOCKERHUB_BARE_REPO=$DOCKERHUB_NAME/$DOCKERHUB_BARE_REPO_body
DOCKERHUB_COMPLETED_REPO=$DOCKERHUB_NAME/$DOCKERHUB_COMPLETED_REPO_body
TAG=latest
IMAGE_FULLNAME=$DOCKERHUB_BARE_REPO:$TAG

###################
# Prepare dockerhub info
###################
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
[[ $repos != *" "$DOCKERHUB_BARE_REPO_body" "* ]] && hubcount=$(($hubcount+1))
[[ $repos != *" "$DOCKERHUB_COMPLETED_REPO_boby" "* ]] && hubcount=$(($hubcount+1))
[ "$hubcount" -gt "0" ] && echo "Please add $DOCKERHUB_BARE_REPO_body and $DOCKERHUB_COMPLETED_REPO_boby in your dockerhub repos." && exit 1

###################
# Explain what will happen
###################
ORG=${3:-cryptoeconomicslab}
BRANCH=${4:-@sg/michelson-level}
echo "Dockerhub Target = $DOCKERHUB_BARE_REPO"
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

echo "Start Building: $IMAGE_FULLNAME"
[ "$SKIP" != "skip" ] && docker image build -t $IMAGE_FULLNAME --ulimit nofile=1024 .
echo "Build Finished."


###################
# Get built images
###################
IMAGES_RAW=`docker images`

###################
# Check target image
###################
if [[ $IMAGES_RAW == *$DOCKERHUB_BARE_REPO*$TAG* ]]; then
  echo "=== Tezos Bare image confirmed. ==="
  ###################
  # Push bare image to Dockerhub
  ###################
  [ "$SKIP" != "skip" ] && docker push $IMAGE_FULLNAME

  ###################
  # Build custom Tezos inside docker
  ###################
  cp ./tezos/scripts/ci/create_docker_image.build.sh /tmp/cdib.sh
  cp ./create_docker_image.build.sh ./tezos/scripts/ci/create_docker_image.build.sh
  cd ./tezos
  scripts/ci/create_docker_image.build.sh $DOCKERHUB_NAME/tezos
  cd ../
  cp /tmp/cdib.sh ./tezos/scripts/ci/create_docker_image.build.sh

  ###################
  # Push completed image to Dockerhub
  ###################
  docker push $DOCKERHUB_COMPLETED_REPO:latest
  echo "=== Tezos has completely been dockerized. ==="
else
 echo "Tezos dockerization failed."
fi
