This directory contains two folders. Deploy and build. This setup uses [ConfigService](https://github.com/Cantara/ConfigService) as an example to demonstrate how we can achieve CI using two scripts to check for newer versions and run a Docker image and a Java application. Docker Hub and a Maven repoistory is used for hosting the built Docker image and Java application respectivly.

# Deploy
Deploy contains [updateDocker.sh](deploy/updateDocker.sh) which is the only file needed to download and run a Docker image.

1. Simply run `./updateDocker.sh`. This will run download and run the Docker image.
2. Running `./updateDocker.sh` again (and again, i.e. from a crontab job) will check for newer versions of the Docker image, and if found, terminate the running image, and start the newer one.
3. You have to define your own crontab to run [updateDocker.sh](deploy/updateDocker.sh) at appropriate intervals.

# Building
The [build](build) folder contains a Docker folder, which is a replica of the Docker folder within ConfigService.

1. The essential part here is that [update-service.sh](build/Docker/toRoot/update-service.sh) will be running repeatedly by a crontab in the Docker container.
2. [update-service.sh](build/Docker/toRoot/update-service.sh) will, like the deploy mechanism, download and run a (Java) application, and check for newer versions to download and run.
3. Here the contab is already included, and will check every minute for newer versions of the app.
4. Before pushing a new Docker image you can test it locally by running `./test-docker.sh`.