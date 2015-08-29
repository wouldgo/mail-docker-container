#!/bin/bash

DEFAULT_HOSTNAME=$(hostname) && \
read -p "Specify the machine hostname [$DEFAULT_HOSTNAME]: " HOSTNAME && \
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME} && \

echo "Specify the admin password for sql server..." && \
read -s PASSWORD && \

read -p "Specify the hostnames managed by this mail container [$HOSTNAME]: " MAIL_HOSTNAMES && \
MAIL_HOSTNAMES=${MAIL_HOSTNAMES:-$HOSTNAME} && \

echo "Hostname $HOSTNAME - SQL user $ADMIN - Mail hostnames $MAIL_HOSTNAMES" && \

docker run \
--name=mailer-data-only-container \
-d \
-h mailer-data-only-container \
-v /var/mail \
-v /var/log \
-v /opt/dkim-pub \
busybox sh -c 'echo mailer-data-only-container' && \

docker run \
--name mailer \
-d \
-h mailer \
--volumes-from=mailer-data-only-container \
-e "HOSTNAME=$(echo $HOSTNAME)" \
-e "PASSWORD=$(echo $PASSWORD)" \
-e "MAIL_HOSTNAMES=$(echo $MAIL_HOSTNAMES)" \
--link mysqld:db \
-p 127.0.0.1:25:25 \
-p 127.0.0.1:587:587 \
-p 127.0.0.1:993:993 \
wouldgo/mail
