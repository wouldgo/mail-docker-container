#!/bin/bash

if [[ $EUID -ne 0 ]]; then

  echo "You must be a root user" 2>&1
  exit 1
else

  useradd \
  --shell /bin/bash \
  --home-dir /home/mail-user \
  --no-create-home \
  --uid 5000 \
  --comment "mail docker container user" \
  vmail || { echo "User for mailer alredy present"; } && \

  docker build --tag wouldgo/mail .
fi
