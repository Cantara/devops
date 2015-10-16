#!/bin/bash
# This file contains all the variables used by updateDocker.sh and update-service.sh,
# for updating the docker image and application, respectivly.

BASE_IMAGE="cantara-configservice"
REGISTRY="itcapra"
IMAGE="$REGISTRY/$BASE_IMAGE"

CONFIG_FILE_NAME=config_override.properties
CONFIG_FILE="$(pwd)/$CONFIG_FILE_NAME"
PORT_MAPPING="8086:8086"
VERSION= # define a version here, like 0.3, or leave it blank, and SNAPSHOT will be used

APP=configservice.jar
START_APP_COMMAND="/usr/bin/java -Dlogback.configurationFile=./logback.xml -jar $APP"

releaseRepo=http://mvnrepo.cantara.no/content/repositories/releases
snapshotRepo=http://mvnrepo.cantara.no/content/repositories/snapshots
groupId=no/cantara/jau
artifactId=configservice

version="${APP_VERSION:-SNAPSHOT}" # default to version SNAPSHOT

# Set these two to something if repository is not open, used by wget and curl
username=
password=
