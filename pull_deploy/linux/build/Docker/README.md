# Running the Docker container 

## How it works
* Configuration override is handled through files in the `config_override/` folder. The scripts in the `application_scripts` folder handle updating, starting and stopping of the hosted application. The `update-service.sh` script is run when building the Docker image, and will create a default `service_config.properties` from the file `config_override_templates/service_override.properties_template`. *This should be the absolute necessity for downloading and running an application.*
* A `cron` job handles automatic updating of the hosted application *if* running SNAPSHOTs. With a release version, the `cron` job will not do anything.

## Prerequisites
* Docker daemon running (see https://wiki.cantara.no/display/FPP/Docker+cheat+sheet)

## Set up
### Change `Dockerfile`
* Update the `USER` environment variable.
* Map the folders you wish to persist to the data volume
* Update the port(s) you wish to expose.

### Supervisord.conf
* Update the `APPLICATION` program entry with user and user's home directory (the `USER` variable from the `Dockerfile`).

### Default configuration
* Update the `config_override_templates/service_override.properties_template` file with your project's artifact repository details as well as a default run configuration for your Java application. 
* Update the default `config_override_templates/logback-default.xml` with desired config.

### Install and run 
* Use the [https://github.com/Cantara/devops/blob/master/pull_deploy/linux/deploy/updateDocker.sh](updateDocker.sh) script, which creates a data-volume and runs an application volume (which uses the data-volume).
* Or run manually (replace the variables):
** `docker create --name $DATA_VOLUME $IMAGE:latest"` for the data volume container
** `docker run -d -p $PORT_MAPPING --name $BASE_IMAGE --restart=always $IMAGE:latest` for the application container.

Connecting to instance for debugging:
```bash
docker exec -it -u $VOLUME_USER $VOLUME_NAME bash
```

## Other configuration
* `logrotate_config` contains configurations for handling log rotation of logs created by the `cron` and `supervisor` programs. Update these if you wish.
* Update the default `config_override_templates/application_override.properties_template` with desired properties for your Java application. *NOTE: You must manually rename/copy this to `application_override.properties` after launching the container if you need application properties to be overridden. This will not be done for you.*

# Finding logs
Logs are saved in the `/var/log/cron.log` file and the `/var/log/supervisor/` directory.

# Reference configuration
* *See the Docker configuration in [https://github.com/Cantara/ConfigService](ConfigService) for a complete configuration based on this.*