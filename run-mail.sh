#!/bin/bash

PWD=$(pwd)

docker run \
-name mailer \
-d \
-h mailer \
-p 0.0.0.0:25:25 \
-p 0.0.0.0:143:143 \
-v $PWD/conf:/opt/conf \
-v $PWD/mails:/opt/mails \
wouldgo/mail
