#!/bin/bash

PWD=$(pwd)

docker run \
-name mailer \
-d \
-h mailer \
-p 127.0.0.1:25:25 \
-p 127.0.0.1:143:143 \
-v $PWD/conf:/opt/confs \
wouldgo/mail
