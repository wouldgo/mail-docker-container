#!/bin/bash

PWD=$(pwd)

docker run \
--name mailer \
-d \
-h mailer \
-v $PWD/mail:/var/mail \
-v $PWD/logs:/var/log \
-p 127.0.0.1:25:25 \
-p 127.0.0.1:587:587 \
-p 127.0.0.1:993:993 \
wouldgo/mail
