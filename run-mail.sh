#!/bin/bash

PWD=$(pwd)

docker run \
--name mailer \
-d \
-h mailer \
-p 127.0.0.1:25:25 \
wouldgo/mail
