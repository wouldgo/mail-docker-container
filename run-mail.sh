#!/bin/bash

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
