#!/bin/bash

docker build -t $BASE_IMAGE-dev .

CONFIG_FILE="$(dirname $(pwd))/config_override.properties"
VERSION=SNAPSHOT

if [ ! -f "$CONFIG_FILE" ]; then
    echo "config_override.properties in parent directory is missing"
    exit 1
fi

LOCAL=""
if [ "$1" == "local" ]; then
    (cd .. && mvn package) || exit 2
    JAR=$(cd ../target && ls -1t *.jar | head -1)
    LOCAL="-v $(dirname $(pwd))/target/$JAR:/home/$BASE_IMAGE/example-app.jar"
fi

echo "Starting instance. Do 'docker exec -it $BASE_IMAGE-dev bash' to get shell"

CONFIG="-v $CONFIG_FILE:/home/$BASE_IMAGE/config_override.properties"

docker run --rm -p 8086:8086 --name configservice-dev $CONFIG $LOCAL configservice-dev

