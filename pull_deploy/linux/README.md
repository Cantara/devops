# The why of this
This is a CI setup that uses the configservice project as an example. All the variables are contained within [var.sh] and can easily be changed to adapt to another project.

# Running it
1. Run `./updateDocker.sh` and this will:
  1. Download and run the Docker image to an instance.
  2. The Docker instance will install a crontab that checks the Maven-repo for updates to your application.
2. Run `./updateDocker.sh` again, and this will check for updates to the docker image, and if needed download and run it.
