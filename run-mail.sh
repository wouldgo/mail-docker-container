#!/bin/bash

PWD=$(pwd)

docker run \
--name mailer \
-d \
-h mailer \
wouldgo/mail
