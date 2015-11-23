# Continuous Integration with Docker, a Java application, and crontab

This directory contains two folders. Deploy and build. This setup uses [ConfigService](https://github.com/Cantara/ConfigService) as an example to demonstrate how we can achieve CI using two scripts to check for newer versions and run a Docker image and a Java application. Docker Hub and a Maven repository is used for hosting the built Docker image and Java application respectivly.

## Deploy
Deploy contains [create_and_run_docker_container.sh](deploy/create_and_run_docker_container.sh) which is the only file needed to download and run a Docker image.

1. Simply run `./create_and_run_docker_container.sh`. This will run download the Docker image, create a data volume container and run an application container (which uses the data volume container) from it.
2. Running `./create_and_run_docker_container.sh` again (and again, e.g. from a crontab job) will check for newer versions of the Docker image, and if found, terminate the running image, and start the newer one. **Once the data volume container has been created, it will not be touched again. As such, you must manually delete it if you need it to be based on an updated Docker image!**
3. You have to define your own crontab to run [create_and_run_docker_container.sh](deploy/create_and_run_docker_container.sh) at appropriate intervals if you want continuous updates of the Docker container itself.

## Building
The [build](build) folder contains a Docker folder with a template for a Docker configuration. Copy this folder into your own project and follow the [README](build/Docker/README.md) to adapt it to your application. _You do not need to copy the `application_scripts` folder. The scripts there are pulled from this repo by the Dockerfile. This allows keeping the scripts up to date between project easier._

1. The essential part here is that [update-service.sh](build/Docker/application_scripts/update-service.sh) will be running repeatedly by a cron job in the Docker container.
2. [update-service.sh](build/Docker/application_scripts/update-service.sh) will, like the deploy mechanism, download and run a (Java) application, and check for newer versions to download and run.
3. Here a crontab is already included, and will check every minute for newer versions of the app.