FROM cantara/zulu
MAINTAINER Erik Drolshammer <erik-dev@fjas.no>

ENV HOME=/home/$BASE_IMAGE
ENV BASE_IMAGE=$BASE_IMAGE
RUN useradd -d "$HOME" -u 500 -m -s /bin/bash $BASE_IMAGE

RUN apt-get update && apt-get install -y --no-install-recommends \
		cron supervisor \
	&& rm -rf /var/lib/apt/lists/*

## Set up start of services
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

## Configure application
COPY toRoot/* $HOME/
RUN chown -R $BASE_IMAGE:$BASE_IMAGE $HOME
RUN chmod 755 $HOME/*.sh

COPY ../vars.sh $HOME/

ADD crontab /etc/cron.d/$BASE_IMAGE
RUN chmod 0644 /etc/cron.d/$BASE_IMAGE

RUN touch /var/log/cron.log
RUN chown $BASE_IMAGE /var/log/cron.log
RUN crontab -u $BASE_IMAGE /etc/cron.d/$BASE_IMAGE

EXPOSE 8082
CMD ["/usr/bin/supervisord"]
