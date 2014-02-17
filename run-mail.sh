#!/bin/bash

PWD=$(pwd)

docker run \
-name mailer \
-d \
-h mailer \
-v /home:/home \
wouldgo/mail
