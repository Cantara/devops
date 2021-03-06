FROM cantara/zulu
MAINTAINER Erik Drolshammer <erik-dev@fjas.no>

ENV USER=hostedapplication
ENV HOME=/home/$USER
RUN useradd -d "$HOME" -u 500 -m -s /bin/bash $USER

RUN apt-get update && apt-get install -y --no-install-recommends \
		supervisor cron logrotate \
	&& rm -rf /var/lib/apt/lists/*

## Fix for python/supervisor error "ImportError: No module named pkg_resources"
RUN wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python

## Set up start of services
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

## Download scripts
ADD https://raw.githubusercontent.com/Cantara/devops/master/pull_deploy/linux/build/Docker/application_scripts/start-service.sh \
    $HOME/start-service.sh
ADD https://raw.githubusercontent.com/Cantara/devops/master/pull_deploy/linux/build/Docker/application_scripts/stop-service.sh \
    $HOME/stop-service.sh
ADD https://raw.githubusercontent.com/Cantara/devops/master/pull_deploy/linux/build/Docker/application_scripts/update-service.sh \
    $HOME/update-service.sh

## Configure application
COPY CRON $HOME/
RUN chmod 755 $HOME/*.sh

##Directories to persist for data volumes
RUN mkdir $HOME/logs
COPY config_override_templates/* $HOME/config_override/

##Configure crontab
ADD crontab /etc/cron.d/$USER
RUN chmod 0644 /etc/cron.d/$USER
RUN touch /var/log/cron.log
RUN chown $USER /var/log/cron.log
RUN crontab -u $USER /etc/cron.d/$USER

##Configure logrotate
COPY logrotate_config/logrotate.conf /etc/logrotate.conf
COPY logrotate_config/logrotate.d/* /etc/logrotate.d/

##Permissions
RUN chown -R $USER:$USER $HOME

##Download application
RUN su - $USER -c "$HOME/update-service.sh"

## Map any additional volumes you want persisted in data volume container
VOLUME ["$HOME/config_override", "$HOME/logs"]

EXPOSE 8086
CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
