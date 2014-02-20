#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else

  mkdir conf

  useradd \
  --shell /bin/bash \
  --home-dir /home/mail-user \
  --no-create-home \
  --uid 9874 \
  --comment "mail docker container user" \
  mail-user || { echo "User for mail alredy present"; }

  echo "Give the hostname"
  read HOSTNAME

  echo "Give the other destinations (comma separated like:
server1.example.com, anotherdomain.com)"
  read DESTINATIONS

  echo "Give the state"
  read STATE

  echo "Give me the province"
  read PROVINCE

  echo "Give me the city"
  read CITY

  echo "Give me the organization"
  read ORG

  if [[ ! $DESTINATIONS = "" ]]; then
    DESTINATIONS=$DESTINATIONS','
  fi

  sed -i -re"s/%HOSTNAME_STRING%/$HOSTNAME/g" Dockerfile && \
  sed -i -re"s/%DESTINATIONS_STRING%/$DESTINATIONS/g" Dockerfile && \
  sed -i -re"s/%STATE_STRING%/$STATE/g" Dockerfile && \
  sed -i -re"s/%PROVINCE_STRING%/$PROVINCE/g" Dockerfile && \
  sed -i -re"s/%CITY_STRING%/$CITY/g" Dockerfile && \
  sed -i -re"s/%ORG_STRING%/$ORG/g" Dockerfile && \
  chown -Rfv mail-user:mail-user conf/ && \
  docker build -rm=true -t wouldgo/mail .
fi