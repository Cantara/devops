#!/bin/bash
# Script to start Java application.
# DO NOT CALL THIS MANUALLY! Intended for use by supervisord only.

date +" --- RUNNING $(basename $0) %Y-%m-%d_%H:%M:%S --- "

JAVA_PARAMS="-Dlogback.configurationFile=./config_override/logback.xml -Xms64m -Xmx256m"
source config_override/service_override.properties # this might override JAVA_PARAMS and version to run

START_APP_COMMAND="/usr/bin/java $JAVA_PARAMS -jar $APP"

echo "Starting $APP"
$START_APP_COMMAND
