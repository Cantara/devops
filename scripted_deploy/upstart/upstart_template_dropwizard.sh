author "Bard Lind"
description "upstart script for sample-dw-service"

# respawn the job up to 5 times within a 10 second period.
# If the job exceeds these values, it will be stopped and
# marked as failed.
respawn
respawn limit 5 10

# move to this service's working directory
chdir /opt/sample-dw-service

script
  # prepare the java command
  LOGS_HOME="/var/log/sample-dw-service"
  JAVA_OPTS="-Xmx128m -Xms128m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$LOGS_HOME"

  # Dropwizard allows command-line arguments with the prefix "dw." to override hard-coded configurations.
  # This is a good way to pass environment-specific configuration, such as database hosts, users and passowrds
  DW_ARGS=""
  #if override config file exists
  if [ -f /etc/sample-dw-service/server.cfg ]; then
    for line in `cat /etc/sample-dw-service/server.cfg`;do
      DW_ARGS="$DW_ARGS -Ddw.$line"
    done
  fi

  # construct the java command and execute it
  JAVA_CMD="java $JAVA_OPTS $DW_ARGS -jar sample-dw-service.jar server server.yml"
  logger -is -t "$UPSTART_JOB" "[`date -u +%Y-%m-%dT%T.%3NZ`] executing: $JAVA_CMD"
  exec $JAVA_CMD >> /tmp/sample-dw-service-upstart.log 2>&1

end script

pre-stop script
  logger -is -t "$UPSTART_JOB" "[`date -u +%Y-%m-%dT%T.%3NZ`] (sys) Stopping"

end script
