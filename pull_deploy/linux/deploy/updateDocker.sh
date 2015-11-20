#!/bin/sh
# Downloads the newest version of a docker image, creates a data volume (if non-existant) and runs an application volume which uses the data volume.
# Replace the BASE_IMAGE, REGISTRY, IMAGE AND POST_MAPPING variables with the docker image you wish to run

set -e
date # for logging
BASE_IMAGE= #"cantara-configservice"
REGISTRY= #"itcapra"
IMAGE= #"$REGISTRY/$BASE_IMAGE"
PORT_MAPPING= #"8086:8086"

DATA_VOLUME="$BASE_IMAGE-data-volume"

DOCKER_CREATE_DATA_VOLUME_COMMAND="docker create --name $DATA_VOLUME $IMAGE:latest"
DOCKER_RUN_COMMAND="docker run -d -p $PORT_MAPPING --name $BASE_IMAGE --restart=always $IMAGE:latest"

DATA_VOLUME_ID=$(docker ps | grep $DATA_VOLUME | awk '{print $1}')
if [ ! -z "$DATA_VOLUME_ID" ]; then
  echo "Data volume $DATA_VOLUME does not exist. Running '$DOCKER_CREATE_DATA_VOLUME_COMMAND'"
  $DOCKER_CREATE_DATA_VOLUME_COMMAND
else 
  echo "Data volume $DATA_VOLUME exists. Not touching it."
fi

CID=$(docker ps | grep $IMAGE | awk '{print $1}')
docker pull $IMAGE

if [ $CID ]; then # if already running
   for im in $CID
      do
          LATEST=`docker inspect --format "{{.Id}}" $IMAGE`
          RUNNING=`docker inspect --format "{{.Image}}" $im`
          NAME=`docker inspect --format '{{.Name}}' $im | sed "s/\///g"`
          echo "Latest:" $LATEST
          echo "Running:" $RUNNING
          if [ "$RUNNING" != "$LATEST" ];then
              echo "upgrading $NAME"
              docker stop $NAME
              docker rm -f $NAME
              echo "Running DOCKER_RUN_COMMAND"
              $DOCKER_RUN_COMMAND
          else
              echo "$NAME is up to date. No changes to running image is done."
          fi
   done
else
   echo "Running '$DOCKER_RUN_COMMAND'"
   $DOCKER_RUN_COMMAND
fi