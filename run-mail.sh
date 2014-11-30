#!/bin/bash

PWD=$(pwd)

if [[ $EUID -ne 0 ]]; then

  echo "You must be a root user" 2>&1
  exit 1
else

  DEFAULT_HOSTNAME=$(hostname) && \
  read -p "Specify the machine hostname [$DEFAULT_HOSTNAME]: " HOSTNAME && \
  HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME} && \

  echo "Specify the admin user for sql server..." && \
  read ADMIN && \

  echo "Specify the admin password for sql server..." && \
  read -s PASSWORD && \

  docker run \
  --name mailer \
  -d \
  -h mailer \
  -v $PWD/mail:/var/mail \
  -v $PWD/logs:/var/log \
  -e "MAIL_HOST=$(echo $HOSTNAME)"
  -e "USER=$(echo $ADMIN)"
  -e "PSW=$(echo $PASSWORD)"
  --link mysqld:db \
  -p 127.0.0.1:25:25 \
  -p 127.0.0.1:587:587 \
  -p 127.0.0.1:993:993 \
  wouldgo/mail
fi
